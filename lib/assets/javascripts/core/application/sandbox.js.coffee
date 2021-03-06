namespace "core"

class core.Sandbox extends core.DependentObject
    @dependency mediator: "Mediator"
    @dependency router: "Router"
    @dependency renderer: "Renderer"
    @dependency application: "Application"
    
    constructor: ( @module ) ->
    
    scoped_name: ( input, opts ) =>
        if opts?.match_subscriptions?
            regex = /^@((\w+)\.)?(\w+)$/
        else
            regex = /^((\w+)\.)?(\w+)$/
            
        if input.match( regex )
            [_, _, scope, event] = regex.exec( input )            
            scope ?= @module.name
            "#{scope}.#{event}"
        else if opts?.validate?
            throw new Error( "Invalid event name: #{input}" )
    
    publish: (event, args...) =>
        scoped_name = @scoped_name( event, validate: true )
        @mediator.publish( scoped_name, args... )
        
    bind_subscriptions: (obj) =>
        for event, handler of obj
            scoped_name = @scoped_name( event, match_subscriptions: true )                
            if scoped_name?
                @mediator.subscribe( scoped_name, handler, obj )

    resolve_module: ( module_name ) =>
        @application.resolve_module( module_name )
        
    resolve_helper: ( helper_name ) =>
        @application.resolve_helper( helper_name )