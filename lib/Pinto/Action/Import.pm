package Pinto::Action::Import;

# ABSTRACT: Import a distribution (and dependencies) into the local repository

use Moose;

use MooseX::Types::Moose qw(Str Bool);

use Exception::Class::TryCatch;

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------
# ISA

extends 'Pinto::Action';

#------------------------------------------------------------------------------
# Moose Attributes

has target => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);


has recurse => (
   is      => 'ro',
   isa     => Bool,
   default => 1,
);

#------------------------------------------------------------------------------
# Moose Roles

with qw(Pinto::Role::UserAgent);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $source = $self->source();
    $self->db->load_index($source) unless $self->soft();

    my $count = 0;
    my $foreigners = $self->db->get_all_distributions_from_source($source);

    while ( my $dist = $foreigners->next() ) {

        my $ok = eval { $count += $self->_do_mirror($dist); 1 };

        if ( !$ok && catch my $e, ['Pinto::Exception'] ) {
            $self->add_exception($e);
            $self->whine($e);
            next;
        }
    }

    return 0 if not $count;
    $self->add_message("Mirrored $count distributions from $source");

    return 1;
}

#------------------------------------------------------------------------------

sub _do_mirror {
    my ($self, $dist) = @_;

    my $archive = $dist->archive( $self->config->root_dir() );

    $self->debug("Skipping $archive: already fetched") and return 0 if -e $archive;
    $self->fetch(url => $dist->url(), to => $archive)   or return 0;

    $self->store->add_archive($archive);

    return 1;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#------------------------------------------------------------------------------

1;

__END__