use strict;
use warnings;

use Data::Sexp;
use Test::TableDriven (
    sexp => [
        # symbols
        [foo => ['foo']],
        ['foo bar' => ['foo', 'bar']],
        ['    foo    bar      ' => ['foo', 'bar']],

        # lists
        ['(foo bar)' => [['foo', 'bar']]],
        ['((foo bar))' => [[['foo', 'bar']]]],
        ['(foo (bar))' => [['foo', ['bar']]]],
        ['((foo) (bar))' => [[['foo'], ['bar']]]],

        # nil
        ['()' => [[]]],
        ['( )' => [[]]],

        # weird spaces
        ['(   (foo  )   (   bar))' => [[['foo'], ['bar']]]],

        # strings
        ['"foo bar"' => ['foo bar']],
        ['("foo bar")' => [['foo bar']]],
        ['(foo "bar")' => [['foo', 'bar']]],
        ['("foo()bar")' => [['foo()bar']]],
        ['("foo)(bar")' => [['foo)(bar']]],
    ],
);

sub sexp {
    my $str = shift;
    return Data::Sexp->new( string => $str )->ast;
}

runtests;
