package Pono::JSON;
use v5.40;
use utf8;

use Exporter 'import';

use Cpanel::JSON::XS ();

our @EXPORT_OK = qw(decode_json encode_json);

our $JSON = Cpanel::JSON::XS->new->utf8(0)->ascii(0)->allow_blessed(1);

sub decode_json { $JSON->decode(@_) };
sub encode_json { $JSON->encode(@_) };
