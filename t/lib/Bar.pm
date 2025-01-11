package Bar;
use v5.40;

sub import { *Foo::Bar::bar = \&bar }

sub bar { 'BAR' }

__END__
