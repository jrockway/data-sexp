package Data::Sexp;
use Mouse;
use 5.010;

has 'ast' => (
    is         => 'ro',
    isa        => 'ArrayRef',
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
    return [$self->_parse($string)];
}

sub _parse {
    my $self = shift;
    my $str = shift;
    my $rest;
    my @atoms;

    $str =~ s/\n+/ /g;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    warn "parse $str";

    if($str =~ /^\(/){
        my ($l, $r) = $self->_parse_list($str);
        push @atoms, $l;
        $rest = $r;
    }
    elsif($str =~ /^\"/){
        my ($l, $r) = $self->_parse_string($str);
        push @atoms, $l;
        $rest = $r;
    }
    elsif($str =~ /^(\S+)\s*(.+)?$/){
        push @atoms, $self->_symbol($1);
        $rest = $2;
    }

    if($rest){
        push @atoms, $self->_parse($rest);
    }
    return @atoms;
}

sub _parse_list {
    my ($self, $str) = @_;

    $str =~ s/^[\(]//; # kill (
    my $depth = 1;

    my @atoms;

    if($str =~ /^([^"]+)?(["].*)$/){
        #push @atoms, $self->_parse($1);
        my ($l, $r) = $self->_parse_string($2);
        $str = $1. $r;
    }

    my $acc;
    while( $str =~ /^([^()]*) ([()]) (.*)$/x ){
        $acc .= $1 if $1;
        $acc .= $2 if $2;

        $depth++ if $2 eq '(';
        $depth-- if $2 eq ')';
        #warn "** $str =~ /({$1} {$2} {$3} / --> $depth";
        $str = $3;
        #warn "acc {$acc} {$str}";

        last if $depth == 0;
    }

    if($depth != 0){
        confess qq{unbalanced parentheses starting with "($acc"};
    }

    $acc =~ s/\)$//; # kill )

    push @atoms, $self->_parse($acc);

    return ([@atoms], $str);
}

sub _parse_string {
    my ($self, $str) = @_;
    $str =~ s/^["]//;

    my $acc;

    while($str){
        warn "testing $str";
        if($str =~ /^[\\](.)(.+)$/){
            warn "found escape $1 in $str ---> $2";
            $acc .= $self->_parse_escape($1);
            $str = $2;
        }
        elsif($str =~ /^["](.*)/){
            warn "found end of string ---> $1";
            return ($self->_string($acc), $1);
        }
        elsif($str =~ /([^\\"]+)(.*)/){
            warn "got $1";
            $acc .= $1;
            $str = $2;
        }
        else {
            confess "unknown parse error!";
        }
    }

    confess qq{unbalanced string literal starting with "$acc};
}

my %ESCAPES = (
    'n'  => "\n",
    't'  => "\t",
    '\\' => "\\",
    '"'  => "\"",
);

sub _parse_escape {
    my ($self, $str) = @_;
    return $ESCAPES{$str} || confess q{\\$str is an invalid escape code};
}

sub _symbol {
    my ($self, $sym) = @_;
    return $sym;
}

sub _string {
    my ($self, $str) = @_;
    return $str;
}

sub _build_string {

}

1;

__END__

=head1 NAME

Data::Sexp -

