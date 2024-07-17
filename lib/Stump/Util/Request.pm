package Stump::Util::Request;
use v5.40;
use utf8;

use Encode ();
use HTTP::Entity::Parser;
use HTTP::Headers::Fast;
use Hash::MultiValue;
use WWW::Form::UrlEncoded ();

use Stump::Request::Upload;

sub decode($env, $v) {
    Encode::decode_utf8($v);
}

sub parse_query($env) {
    my $parsed = WWW::Form::UrlEncoded::parse_urlencoded_arrayref($env->{QUERY_STRING});
    Hash::MultiValue->new( map { decode($env, $_) } $parsed->@* );
}

sub match_content_type($env, $content_type) {
    my $ct = $env->{CONTENT_TYPE} || '';
    $ct eq $content_type || index($ct, $content_type) == 0;
}

sub parse_form_data($env) {
    my ($params, $uploads) = form_data_parser($env)->parse($env);

    my $decoded_params = Hash::MultiValue->new(map { decode($env, $_) } $params->@*);

    my $upload_hash = Hash::MultiValue->new();
    for my ($k, $v) ($uploads->@*) {
        my %copy = %$v;
        $copy{headers} = HTTP::Headers::Fast->new(@{$v->{headers}});
        $upload_hash->add($k, Stump::Request::Upload->new(%copy));
    }

    return {
        data    => $decoded_params,
        uploads => $upload_hash,
    }
}

sub form_data_parser($env) {
    my $parser = HTTP::Entity::Parser->new(buffer_lentgh => buffer_length($env));
    $parser->register('application/x-www-form-urlencoded', 'HTTP::Entity::Parser::UrlEncoded');
    $parser->register('multipart/form-data', 'HTTP::Entity::Parser::MultiPart');
    $parser;
}

sub parse_json($env) {
    if (match_content_type($env, 'application/json')) {
        my $decoded_body = decode($env, raw_body($env));
        my $json = Stump::JSON::decode_json($decoded_body, my $json_type);
        return {
            json      => $json,
            json_type => $json_type,
        }
    }
    else {
        return {
            json      => {},
            json_type => {},
        }
    }
}

sub raw_body($env) {
    my $fh = $env->{'psgi.input'} or return '';
    my $cl = $env->{CONTENT_LENGTH} or return '';

    $fh->seek(0, 0); # just in case middleware/apps read it without seeking back
    $fh->read(my($content), $cl, 0);
    $fh->seek(0, 0);

    return $content;
}

sub headers($env) {
    HTTP::Headers::Fast->new(
        map {
            (my $field = $_) =~ s/^HTTPS?_//;
            ( lc($field) => $env->{$_} );
        }
        grep { /^(?:HTTP|CONTENT)_/ } keys %$env
    );
}

sub buffer_length($env) {
    return $ENV{PLACK_BUFFER_LENGTH} if defined $ENV{PLACK_BUFFER_LENGTH};

    if ($env->{'psgix.input.buffered'}) {
        return 1024 * 1024; # 1MB for buffered
    } else {
        return 1024 * 64; # 64K for unbuffered
    }
}
