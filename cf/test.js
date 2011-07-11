test( 'cf', function(){
    ok( true );
} );

test( 'promise', function(){
    var value;

    value = 0;
    $.ajax({
        type: 'GET',
        url: 'http://google.com',
        async: false
    })
    .success( function(){
        value += 1;
    } )
    .error( function(){
        throw "Xyzzy0";
        value += 1;
    } )
    .complete( function(){
        throw "Xyzzy";
    } )
    .complete( function(){
        value += 1;
        throw "Xyzzy1";
    } )
    ;
    equal( value, 2 );

} );

test( 'afterPromise', function(){
    ok( true )
} );
