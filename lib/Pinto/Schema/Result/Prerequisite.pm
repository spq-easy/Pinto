use utf8;
package Pinto::Schema::Result::Prerequisite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Pinto::Schema::Result::Prerequisite

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<prerequisite>

=cut

__PACKAGE__->table("prerequisite");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 distribution

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 version

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "distribution",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "version",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 distribution

Type: belongs_to

Related object: L<Pinto::Schema::Result::Distribution>

=cut

__PACKAGE__->belongs_to(
  "distribution",
  "Pinto::Schema::Result::Distribution",
  { id => "distribution" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-21 21:53:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:q9BQdlXApf0PBxCycyQBzw

#------------------------------------------------------------------------------

use Pinto::PackageSpec;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

sub as_spec {
    my ($self) = @_;

    return Pinto::PackageSpec->new( name    => $self->name,
                                    version => $self->version );
}

#------------------------------------------------------------------------------
1;

__END__
