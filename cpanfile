#requires 'perl', '5.008001';

requires 'WWW::Form::UrlEncoded';
recommends 'WWW::Form::UrlEncoded::XS';

requires 'Cpanel::JSON::XS';
requires 'Encode';
requires 'HTTP::Entity::Parser';
requires 'HTTP::Headers::Fast';
requires 'Hash::MultiValue';

requires 'HTTP::Parser';
recommends 'HTTP::Parser::XS';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Plack';
};

