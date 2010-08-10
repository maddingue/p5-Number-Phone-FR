use utf8;
use strict;
use warnings;

package Number::Phone::FR;

our $VERSION = '0.01';

use Carp;
use Number::Phone;

use base 'Number::Phone';


sub country_code() { 33 }

#$Number::Phone::subclasses{country_code()} = __PACKAGE__;

use Scalar::Util 'blessed';

our $use_cache = 1;
my %cache;

{
sub RE() {
  qr{
  ^ (?:
    1 (?:
        0[0-9]{2}  # Opérateur
      | 5          # SAMU
      | 7          # Police/gendarmerie
      | 8          # Pompiers
      | 1 (?:
            2      # Numéro d'urgence européen
          | 5      # Urgences sociales
	  | [68][0-9]{3}  # 116000 : Enfance maltraitée
                          # 118XYZ : Renseignements téléphoniques
	  | 9      # Enfance maltraitée
	  )
      )
  | 3(?:[0-9]{3})
  | (?:
       \+33        # Préfixe international
     | [04789]     # Transporteur par défaut (0) ou Sélection du transporteur
     | 16 [0-9]{2} # Sélection du transporteur
    ) [0-9]{9}     # Numéro de ligne
  ) $
  }xs
}

}




sub new
{
    my $class = shift;
    my $number = shift;
    croak "No number given to ".__PACKAGE__."->new()\n" unless defined $number;
    croak "Invalid phone number (scalar expected)" if ref $number;
    my $num = $number;
    $num =~ s/[^+0-9]//g;
    return Number::Phone->new("+$1") if $num =~ /^(?:\+|00)((?:[^3]|3[^3]).*)$/;

    return is_valid($number) ? bless(\$num, $class) : undef;
}



sub _parse
{
    my $number = (@_);
    $number =~ s/[^0-9+]//g;
    #if ($number !~ RE) return undef;
}

sub is_valid
{
    my ($number) = (@_);
    return 1 if blessed($number) && $number->isa(__PACKAGE__);

    if ($use_cache && exists $cache{$number}) {
	return $cache{$number}->{is_valid};
    }
    #print "is_valid($number)\n";
    #print RE."\n";
    my $is_valid = $number =~ RE;
    $cache{$number} = {
	is_valid => $is_valid,
    };
    return $is_valid;
}


1;
__END__
=head1 NAME

Number::Phone::FR - Phone number information for France (+33)

=head1 DESCRIPTION

This is a subclass of L<Number::Phone> that provide information for phone numbers in France.

=head1 DATA SOURCES

L<http://www.arcep.fr/index.php?id=8992>

=head1 SEE ALSO

L<http://fr.wikipedia.org/wiki/Plan_de_num%C3%A9rotation_t%C3%A9l%C3%A9phonique_en_France>

=head1 SUPPORT

L<http://rt.cpan.org/>

=head1 AUTHOR

Copyright E<copy> 2010 Olivier Mengué

=cut
