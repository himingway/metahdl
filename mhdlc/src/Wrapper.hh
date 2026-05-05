#ifndef __WRAPPER_HH__
#define __WRAPPER_HH__

#include "location.hh"

#include <cstring>
#include <libgen.h>

#include <map>
#include <vector>
#include <string>

using namespace std;

#include "vpp.hh"
#include "Table.hh"
#include "Mfunc.hh"

extern bool PreservePostPPFile;

class CWarningLocMessage
{
private:
  yy::location loc;
  string msg;

public:
  inline CWarningLocMessage (const yy::location &loc_, const string &msg_)  :
    loc (loc_), msg (msg_) {};

  inline ostream& Print(ostream &os=cerr) {
    if (UseColor()) os << "\033[00;35m";
    os << "\n**WARNING:" << loc << ":" << msg;
    if (UseColor()) os << "\033[00m";
    os << endl;
    return os;
  }
};

// ------------------------------
//   Wrapper base class
// ------------------------------
class CWrapper
{
public:
  string filename;
  string path, workdir;
  string module_name;
  string extension;
  string post_pp_file;
  string gen_file;
  yy::location module_location;

  bool is_global_param;


  CIOTab* io_table;
  CParamTab* param_table;
  CSymbolTab *symbol_table;

private:
  string _my_name;

protected:
  vector<CWarningLocMessage*> _warning_msg;
  vector<string> _lint_warning_msg;
  set<string> _lint_warning_flag;


public:
  inline CWrapper() : io_table(NULL), param_table(NULL), symbol_table(NULL) {};
  inline CWrapper(string f, string n) : is_global_param (false), filename (f), _my_name (n),
    io_table(NULL), param_table(NULL), symbol_table(NULL) {
    DecomposeName();
    SetPostPPFile();

    gen_file = module_name;
  }

  inline void RunPP() const
  {
    FILE *in, *out;

    in  = fopen(filename.c_str(), "r");
    out = fopen(post_pp_file.c_str(), "w");

    if ( in && out ) {
      int i = preprocess(in, filename, out);
	fclose(in);
	fclose(out);
	if ( i ) {
	  throw CompileError("**Preprocessor Error: Preprocessor syntax error on file: " + filename);
	}
    }
    else {
      string err = "**Preprocessor Error: ";
      if ( !in ) {
	err += filename + " cannot be opened for read. ";
      }
      if ( !out ) {
	err += post_pp_file + " cannot be opened for write.";
      }
      throw CompileError(err);
    }
  }


  inline void DecomposeName()
  {
    size_t pos ;
    string base_filename;

    char *str = (char *)calloc(1, strlen(filename.c_str())+1);
    strcpy(str, filename.c_str());
    path = dirname(str);

    strcpy(str, filename.c_str());
    base_filename = basename(str);

    pos = base_filename.find_last_of(".");
    if ( pos == string::npos ) {
        module_name  = base_filename;
        extension   = "";
    }
    else {
      module_name  = base_filename.substr(0, pos);
      extension    = base_filename.substr(pos);
    }

    if (MIRROR.count(path) > 0)
        workdir = MIRROR[path];
    else
        workdir = V_BASE;
  }

  inline void SetPostPPFile()
  {
    post_pp_file = workdir + "/" + module_name + extension + ".postpp";
  }

  virtual inline void RemovePostPPFile() {
    if ( !PreservePostPPFile )
      if ( unlink(post_pp_file.c_str()) ) {
	cerr << "Cannot unlink " << post_pp_file << endl;
      }
  }

  virtual inline string GetGenFileName()
  {
    if ( extension == ".mhdl" )
      return workdir + "/" + gen_file + ".sv";
    else
      return workdir + "/" + gen_file + extension;
  }

  inline void error(const int lineno, const string &msg) const {
    ostringstream oss;
    if (UseColor()) oss << "\033[00;31m";
    oss << "\n**" << _my_name << " Lexer ERROR:" << filename << ":" << lineno << ":" << msg;
    if (UseColor()) oss << "\033[00m";
    throw CompileError(oss.str());
  }

  inline  void error(const yy::position &pos, const string &msg) const {
    ostringstream oss;
    if (UseColor()) oss << "\033[00;31m";
    oss << "\n**" << _my_name << " Lexer ERROR:" << pos << ":" << msg;
    if (UseColor()) oss << "\033[00m";
    throw CompileError(oss.str());
  }

  inline void error(const yy::location &loc, const string &msg) const {
    ostringstream oss;
    if (UseColor()) oss << "\033[00;31m";
    oss << "\n**" << _my_name << " Parser ERROR:" << loc << ":" << msg;
    if (UseColor()) oss << "\033[00m";
    throw CompileError(oss.str());
  }

  virtual inline void warning(const yy::location &loc, const string &msg)  {
    if (UseColor()) cerr << "\033[00;35m";
    cerr << "\n**" << _my_name << " Parser WARNING:" << loc << ":" << msg;
    if (UseColor()) cerr << "\033[00m";
    cerr << endl;
  }
};


class CCtrlValType
{
public:
  string str;
  bool   flag;
  ulonglong num;

public:
  inline CCtrlValType() : str (""), flag (false), num (0) {}

};



// ------------------------------
//   Extern G_ModuleTable
// ------------------------------
extern CModTab G_ModuleTable;


// ------------------------------
//   MHDL Wrapper
// ------------------------------
class CMHDLwrapper : public CWrapper
{
public:
  bool in_fsm, fsm_nc;
  bool in_sequential;
  string fsm_name, fsm_clk_name, fsm_rst_name;
  CSymbol *fsm_clk, *fsm_rst;
  string state_name;
  map<string, CStTransition*> *state_graph;
  vector<CCodeBlock*> *code_blocks;
  CModule *mod_template;
  string mod_template_name;
  map<string, int> mod_inst_cnt;
  map<string, CCtrlValType*> mctrl;
  set<string> symbol_to_remove;
  set<string> for_iter_var;

private:
  inline CMHDLwrapper() {};

public:
  inline CMHDLwrapper(string f) : CWrapper(f, "MHDL")
  {
    in_fsm = false;
    fsm_nc = false;
    in_sequential = false;

    state_graph  = NULL;
    code_blocks  = new vector<CCodeBlock*>;
    mod_template = NULL;

    io_table     = new CIOTab;
    param_table  = new CParamTab;
    symbol_table = new CSymbolTab;

    mctrl["modname"] = new CCtrlValType;
    mctrl["modname"]->str = module_name;

    mctrl["portchk"] = new CCtrlValType;

    mctrl["outfile"] = new CCtrlValType;
    mctrl["outfile"]->str = gen_file;

    mctrl["hierachydepth"] = new CCtrlValType;
    mctrl["hierachydepth"]->num = 300;

    mctrl["clock"] = new CCtrlValType;
    mctrl["clock"]->str = "clk";

    mctrl["reset"] = new CCtrlValType;
    mctrl["reset"]->str = "rst_n";

    mctrl["multidriverchk"] = new CCtrlValType;
    mctrl["multidriverchk"]->flag = true;

    mctrl["relaxedfsm"] = new CCtrlValType;
    mctrl["relaxedfsm"]->flag = true;

    mctrl["exitonwarning"] = new CCtrlValType;
    mctrl["exitonlintwarning"] = new CCtrlValType;

    mctrl["exitonportchk"] = new CCtrlValType;
    mctrl["exitonportchk"]->flag = true;

    mctrl["exitonmultidriver"] = new CCtrlValType;

  }

  inline void LintWarning(const string &msg, const string &exit_switch="exitonlintwarning")  {
    _lint_warning_msg.push_back(msg);
    _lint_warning_flag.insert(exit_switch);
  }


  // MHDL specific interface
  void OpenIO() ;
  void CloseIO() ;
  void Parse();


  void SwitchLexerSrc();
  void RestoreLexerSrc();
  int  HierDepth();
  void DepParse();

  inline string GetGenFileName() {
    if ( LEGACY_VERILOG_MODE ) {
      return workdir + "/" + mctrl["outfile"]->str + ".v";
    }
    else {
      return workdir + "/" + mctrl["outfile"]->str + ".sv";
    }
  }

  inline void GenSV() {
    CModule *mod = G_ModuleTable.Exist(mctrl["modname"]->str);
    if ( mod ) {
      cerr << "Module " << mctrl["modname"]->str << " already exists in module database (" << mod->loc << "), drop MHDL parse result." << endl;
      delete io_table;
      delete param_table;
      delete code_blocks;
      delete symbol_table;
    }
    else {
      // port checking
      string msg = symbol_table->ExtractIO(io_table);
      if ( mctrl["portchk"]->flag ) {
	msg  += io_table->ChkMissingPort();
	if ( msg != "" ) {
	  LintWarning("Port checking:\n" + msg + "\n", "exitonportchk");
	}
      }


      // multi-driver checking
      if ( mctrl["multidriverchk"]->flag ) {
	msg = "";
	msg = symbol_table->ChkMultiDriver();
	if ( msg != "" ) {
	  LintWarning("Multiple Driver Report:\n" + msg, "exitonmultidriver");
	}
      }

      mod = new CModMHDL (module_location, mctrl["modname"]->str,
			  io_table, param_table, code_blocks, symbol_table);
      G_ModuleTable.Insert(mod);

      ofstream outfile;
      outfile.open(GetGenFileName().c_str());
      if ( outfile.is_open() ) {
	mod->Print(outfile);
	outfile.close();

	cerr << "Module \"" << mctrl["modname"]->str << "\" is created in " << GetGenFileName() << endl;
      }
      else {
	throw CompileError("**MWrapper Error: Cannot open file " + GetGenFileName());
      }

      for (vector<CWarningLocMessage*>::iterator iter = _warning_msg.begin();
	   iter != _warning_msg.end(); iter++) {
	(*iter)->Print(cerr);
      }
      if ( mctrl["exitonwarning"]->flag ) {
	throw CompileError("exit-on-warning set for module " + mctrl["modname"]->str);
      }

      if (_lint_warning_msg.size()) {
	if (UseColor()) cerr << "\033[00;35m";
	cerr << endl
	     << "**Lint Warning on Module \""
	     << mctrl["modname"]->str << "\":";
	if (UseColor()) cerr << "\033[00m";
	cerr << endl;
      }
      for (vector<string>::iterator iter = _lint_warning_msg.begin();
	   iter != _lint_warning_msg.end(); iter++) {
	if (UseColor()) cerr << "\033[00;35m";
	cerr << (*iter);
	if (UseColor()) cerr << "\033[00m";
	cerr << endl;
      }
      if (mctrl["exitonlintwarning"]->flag && _lint_warning_msg.size() > 0) {
	cerr << "\"exitonlintwarning\" set for module "
	     << mctrl["modname"]->str
	     << ", fix warning or remove this option to continue." << endl;
	throw CompileError("exitonlintwarning");
      }
      else if (mctrl["exitonportchk"]->flag && _lint_warning_flag.count("exitonportchk") > 0) {
	cerr << "\"exitonportchk\" set for module "
	     << mctrl["modname"]->str
	     << ", fix warning or remove this option to continue." << endl;
	throw CompileError("exitonportchk");
      }
      else if (mctrl["exitonmultidriver"]->flag && _lint_warning_flag.count("exitonmultidriver") > 0) {
	cerr << "\"exitonmultidriver\" set for module "
	     << mctrl["modname"]->str
	     << ", fix warning or remove this option to continue." << endl;
	throw CompileError("exitonmultidriver");
      }
    }
  }

  inline bool SetCtrl(const string &name, bool flag) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->flag = flag;
      return true;
    }
    else {
      return false;
    }
  }

  inline bool SetCtrl(const string &name, const string &str) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->str = str;
      return true;
    }
    else {
      return false;
    }
  }

  inline bool SetCtrl(const string &name, ulonglong num) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->num = num;
      return true;
    }
    else {
      return false;
    }
  }



};

class CSVwrapper : public CWrapper
{
private:
  inline CSVwrapper() {}

public:
  // Base class no longer allocates tables; svparser.y constructs them
  inline CSVwrapper(string f) : CWrapper(f, "SV") {};


  void OpenIO() ;
  void CloseIO() ;
  void Parse();

  inline  void BuildModule()
  {
    CModule *mod = G_ModuleTable.Exist(module_name);
    if ( mod ) {
      cerr << "Module " << module_name << " already exists in module database (" << mod->loc << "), drop SV parse result." << endl;
      delete io_table;
      delete param_table;
      delete symbol_table;
    }
    else {
      mod = new CModSV (module_location, module_name, io_table, param_table);
      G_ModuleTable.Insert(mod);
    }
  }
};



#endif
