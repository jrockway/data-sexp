use inc::Module::Install;

name 'Data-Sexp';
all_from 'lib/Data/Sexp.pm';

build_requires 'Test::More';
build_requires 'Test::TableDriven';
build_requires 'ok';

WriteAll();
