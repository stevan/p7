
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

class Consumer {
    field $f :param :reader;

    method accept($e) { $f->($e); return }

    method and_then ($g) {
        __CLASS__->new( f => sub ($e) { $f->($e); $g->($e); return } )
    }
}
