
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

use org::p7::core::util qw[ Logging ];

use Supplier;

class Function {
    field $f :param :reader;

    method apply ($t) { LOG $self, { t => $t } if DEBUG; return $f->($t); }

    method curry    ($t) { Supplier ->new( f => sub      { return $f->($t) } ) }
    method compose  ($g) { __CLASS__->new( f => sub ($t) { return $f->($g->($t)) } ) }
    method and_then ($g) { __CLASS__->new( f => sub ($t) { return $g->($f->($t)) } ) }
}
