# ABSTRACT: Something pulls packages to a stack

package Pinto::Role::Puller;

use Moose::Role;
use MooseX::Types::Moose qw(Bool);
use MooseX::MarkAsMethods (autoclean => 1);

#-----------------------------------------------------------------------------

# VERSION

#-----------------------------------------------------------------------------

with qw( Pinto::Role::Plated );

#-----------------------------------------------------------------------------

has no_recurse => (
	is          => 'ro',
	isa         => Bool,
	default     => 0,
);


has pin => (
  is          => 'ro',
  isa         => Bool,
  default     => 0,
);

#-----------------------------------------------------------------------------

# We should require a stack() attribute, but I can't get it to work 
# when composing with the Committable role which provides it.
# requires qw(stack);

#-----------------------------------------------------------------------------

sub pull {
	my ($self, %args) = @_;

	my $target = $args{target};
	my $stack  = $self->stack;

  my $dist = $target->isa('Pinto::Schema::Result::Distribution') ?
    $target : $self->find(target => $target);

  $dist->register(stack => $stack, pin => $self->pin);
  $self->recurse(start => $dist) unless $self->no_recurse;

  return $dist;
}

#-----------------------------------------------------------------------------

sub find {
  my ($self, %args) = @_;

  my $target = $args{target};
  my $stack  = $self->stack;

  my $dist = $stack->get_distribution(spec => $target)
    || $stack->repo->get_distribution(spec => $target)
    || $stack->repo->ups_distribution(spec => $target);

  return $dist;
}

#-----------------------------------------------------------------------------

sub recurse {
  my ($self, %args) = @_;

  my $dist  = $args{start};
  my $stack = $self->stack;

  my %latest;
  my $cb = sub {
    my ($prereq) = @_;

    my $pkg_name = $prereq->name;
    my $pkg_vers = $prereq->version;

    # version sees undef and 0 as equal, so must also check definedness 
    # when deciding if we've seen this version (or newer) of the packge
    return if defined($latest{$pkg_name}) && $pkg_vers <= $latest{$pkg_name};

    # I think the only time that we won't see a $dist here is when
    # the prereq resolves to a perl (i.e. its a core-only module).
    return if not my $dist = $self->find(target => $prereq);

    $dist->register(stack => $stack);
    $latest{$pkg_name} = $pkg_vers;

    return $dist;
  };

  require Pinto::PrerequisiteWalker;
  require Pinto::PrerequisiteFilter::Core;

  my $tpv    = $stack->target_perl_version;
  my $filter = Pinto::PrerequisiteFilter::Core->new(perl_version => $tpv);
  my $walker = Pinto::PrerequisiteWalker->new(start => $dist, callback => $cb, filter => $filter);
    
  while ($walker->next){}  # We just want the side effects of the callback

  return $self;
}

#-----------------------------------------------------------------------------
1;

__END__