
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::core::compiler ];

use org::p7::core::util qw[ Logging ];

class Deparser::Tree {
    field $node :param :reader = undef;
    field @children    :reader;

    method is_root { defined $node }

    method add_children (@c) { push @children => @c }

    method accept ($v) {
        $v->visit($self, map { $_->accept($v) } @children);
    }

    method traverse ($f, $depth=0) {
        $f->($self, $depth);
        foreach my $child (@children) {
            $child->traverse( $f, $depth + 1 );
        }
    }

    method to_JSON {
        return +{
            node     => $node->to_string,
            children => [ map $_->to_JSON, @children ],
        }
    }
}
