
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

use org::p7::core::util qw[ Logger ];

class BiConsumer {
    field $f :param :reader;

    method accept($t, $u) { LOG $self, { t => $t, u => $u } if DEBUG; $f->($t, $u); return }

    method and_then ($g) {
        __CLASS__->new( f => sub ($t, $u) { $f->($t, $u); $g->($t, $u); return } )
    }
}
