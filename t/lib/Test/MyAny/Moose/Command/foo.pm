package Test::MyAny::Moose::Command::foo;
use Moose;

extends 'MooseX::App::Cmd::Command';

has bar => (
    isa           => 'Str',
    is            => 'ro',
    required      => 1,
    documentation => 'required option field',
);

sub execute {
    my ( $self, $opt, $arg ) = @_;

    die 'my Moose bar is ', $self->bar . "\n";
}

1;
