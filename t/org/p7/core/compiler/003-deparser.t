
use v5.40;
use experimental qw[ class ];

use lib 't/lib';

use Test::More;
use Test::Differences;

use org::p7::core::compiler qw[ Decompiler Deparser ];

sub print_ops (@ops) { print_op($_) foreach @ops }
sub print_op  ($op)  { say stringify_op($op)     }

sub stringify_op ($op) {
    sprintf '%15s:%04d │ %s%s' =>
            $op->statement->file,
            $op->statement->line,
            ('  ' x $op->depth),
            $op;
}

sub print_tree ($tree) {
    $tree->traverse(sub ($n, $depth) {
        say(('  ' x $depth), $n->node->to_string);
    });
}

package Foo::Bar {
    use Foo;

    sub foobar ($x) {
        my $foo = 10;
        {
            my $bar = 100;
            foreach my $x ( 1 .. 100 ) {
                my $baz = ($foo + 5);

                $bar += Foo::foo($x * $baz);
            }
        }
    }
}

Decompiler->new( from => \&Foo::Bar::foobar )->stream->foreach(\&print_op);

my $stream = Decompiler->new( from => \&Foo::Bar::foobar )->stream;
my $parser = Deparser->new( stream => $stream );
my $result = $parser->parse;

die $result // '!!!!' unless defined $result && blessed $result;

print_tree($result);

done_testing;

__END__

