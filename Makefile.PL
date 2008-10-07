use inc::Module::Install;

name 'Data-Sexp';
all_from 'lib/Data/Sexp.pm';

requires 'Mouse';
build_requires 'Test::More';
build_requires 'ok';

WriteAll();
