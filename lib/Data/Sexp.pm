package Data::Sexp;
use Mouse;
use 5.010; # for the new regexp syntax

has 'ast' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'string' => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

sub BUILD {
    my $self = shift;
    confess 'you fail'
      unless $self->has_ast || $self->has_string;
}

sub _build_ast {
    my $self = shift;
    my $string = $self->string;

    return _build_ast1($string);
}

# sub called with match
# string = call end_{$state}, state change
my %STATE_TABLE = (
    '' => {
        '('          => 'list',
        '"'          => 'quoted_string',
        '\s'         => sub { },
        '/[^")\s]+/' => sub { _mk_atom($_[0]) },
    },
    list => {
        ')' => '',
    },
);

my $REGEX_KEY_STYLE = qr{^/.+/$};

sub _build_ast1 {
    my $string = shift;
    my $state  = shift;

    my %actions = %{$STATE_TABLE{$state} || confess "invalid state $state"};

    my @state_changes = grep { !m{$REGEX_KEY_STYLE} } keys %actions;

    my ($chr, $rest) = ( $string =~ m{^(.)(.+)$} );

    if( $chr ~~ @state_changes ) {
        return _build_ast1( $rest, $actions{$chr} );
    }

    my @regexen = map { qr/(?<match>$_)/ }
        map { m{(?<re>$REGEX_KEY_STYLE)}; $+{re} }
        grep { m{$REGEX_KEY_STYLE} } keys %actions;

    for my $r (@regexen) {

    }

}

sub _mk_atom {
    my $text = shift;
    return Data::Sexp::Symbol->new( symbol => $text );
}

sub _build_string {

}

1;

__END__

=head1 NAME

Data::Sexp -

