
use v5.40;
use experimental qw[ class ];

use B ();
BEGIN { B::save_BEGINs(); }

class org::p7::core::compiler :isa(module) {}
