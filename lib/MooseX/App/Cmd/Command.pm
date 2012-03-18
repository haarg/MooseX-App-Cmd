use 5.006;

package MooseX::App::Cmd::Command;
use Moose;

# VERSION
use Getopt::Long::Descriptive ();
use MooseX::Has::Options;
extends qw(Moose::Object App::Cmd::Command);
with 'MooseX::Getopt';

has usage => (
    qw(:ro :required),
    metaclass => 'NoGetopt',
    isa       => "Object",
);

has app => (
    qw(:ro :required),
    metaclass => 'NoGetopt',
    isa       => 'MooseX::App::Cmd',
);

sub _process_args {
    my ( $class, $args, @params ) = @_;
    local @ARGV = @$args;

    my $config_from_file;
    if ( $class->meta->does_role('MooseX::ConfigFromFile') ) {
        local @ARGV = @ARGV;

        my $configfile;
        my $opt_parser = Getopt::Long::Parser->new(
            config => [
                qw( pass_through
                    ),
            ],
        );
        $opt_parser->getoptions( 'configfile=s' => \$configfile );
        if ( !defined $configfile ) {
            my $cfmeta = $class->meta->find_attribute_by_name('configfile');
            $configfile = $cfmeta->default if $cfmeta->has_default;
        }

        if ( defined $configfile ) {
            $config_from_file = $class->get_config_from_file($configfile);
        }
    }

    my %processed = $class->_parse_argv(
        params => { argv => \@ARGV },
        options => [ $class->_attrs_to_options($config_from_file) ],
    );

    return (
        $processed{params},
        $processed{argv},
        usage => $processed{usage},

        # params from CLI are also fields in MooseX::Getopt
        %{  $config_from_file
            ? { %$config_from_file, %{ $processed{params} } }
            : $processed{params}
            },
    );
}

sub _usage_format {
    my $class = shift;
    return $class->usage_desc();
}

__PACKAGE__->meta->make_immutable();
no Moose;
1;

# ABSTRACT: Base class for MooseX::Getopt based App::Cmd::Commands

=head1 SYNOPSIS

    use Moose;

    extends qw(MooseX::App::Cmd::Command);

    # no need to set opt_spec
    # see MooseX::Getopt for documentation on how to specify options
    has option_field => (
        isa => 'Str',
        is  => 'rw',
        required => 1,
    );

    sub execute {
        my ( $self, $opts, $args ) = @_;

        print $self->option_field; # also available in $opts->{option_field}
    }

=head1 DESCRIPTION

This is a replacement base class for L<App::Cmd::Command|App::Cmd::Command>
classes that includes
L<MooseX::Getopt|MooseX::Getopt> and the glue to combine the two.

=method _process_args

Replaces L<App::Cmd::Command|App::Cmd::Command>'s argument processing in favor
of L<MooseX::Getopt|MooseX::Getopt> based processing.

=head1 TODO

Full support for L<Getopt::Long::Descriptive|Getopt::Long::Descriptive>'s
abilities is not yet written.

This entails taking apart the attributes and getting at the descriptions.

This might actually be added upstream to L<MooseX::Getopt|MooseX::Getopt>, so
until we decide here's a functional but not very helpful (to the user) version
anyway.
