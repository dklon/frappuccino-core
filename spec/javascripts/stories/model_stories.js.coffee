#= require helpers/test_bootstrapper

feature "core.Model", ->
        
    summary(
        'As a client of the framework',
        'I want to create, read, update and destory resources through a repository'
    )

    scenario "initialize model classes", ->
    
        app = bootstrapper = Blog = BlogPost = null
        
        Given "I have an application and a bootstrapper", ->
            app = new core.Application
            bootstrapper = test_helper.Bootstrapper()
        
        When "I configure and run the application with the bootstrapper", ->
            Blog = class extends core.Model
                @attr "id"
                @attr "title"
                @has_many "blog_posts"

                @attr_serialize "title", "blog_posts"
                
            BlogPost = class extends core.Model
                @attr "id"
                @attr "content"

                @attr_serialize "content"
                
            app.config "app.models",
                Blog: Blog
                BlogPost: BlogPost
                
            app.run( bootstrapper )
            
        Then "the application environment should be configured with the application models", ->
            #my_model = app.env.create( "my_model" )
            #expect( my_model instanceof MyModel ).toBe true
            
            #my_model = new MyModel()
            #expect( my_model instanceof MyModel ).toBe true
            #expect( my_model.env ).toBe app.env
            
        And "the serialize method should serialize accessible attributes by default", ->
            blog = new Blog
                title: "blog title"

            expected_json =
                title: "blog title"
            
            expect( blog.serialize() ).toEqual( expected_json )
            
        And "the serialize method should follow accessible associations", ->
        
            blog = new Blog
                title: "blog title"
                blog_posts: [ content: "some example content" ]
                
            expected_json =
                title: "blog title"
                blog_posts_attributes: [ content: "some example content" ]

            expect( blog.serialize() ).toEqual( expected_json )
            
        And "the serialize method should include primary keys for nested associations", ->
            blog = new Blog
                id: 1
                title: "blog title"
                blog_posts: [ id: 2, content: "some example content" ]
                
            expected_json =
                title: "blog title"
                blog_posts_attributes: [ id: 2, content: "some example content" ]

            expect( blog.serialize() ).toEqual( expected_json )
            
            #expect( blog.serialize() ).toEqual( blog_posts: [ id: 1, content: "some example content" ] )
            
        And "the serialize method should only include specified attributes (if provided), and primary keys", ->
            blog = new Blog
                id: 1
                title: "blog title"
                blog_posts: [ id: 2, content: "some example content" ]
                
            expected_json =
                blog_posts_attributes: [ id: 2, content: "some example content" ]
            
            expect( blog.serialize( include: { blog_posts: { content: true } } ) ).toEqual( expected_json )

        And "the serialize method should mark deleted items to be destroyed", ->
            blog = new Blog
                id: 1
                title: "blog title"
                blog_posts: [ id: 2, content: "some example content" ]
                
            expected_json =
                title: "blog title"
                blog_posts_attributes: [ id: 2, content: "some example content", _destroy: 1 ]
            
            blog.blog_posts()[0].destroy()
            
            expect( blog.serialize() ).toEqual( expected_json )
            
        And "the serialize method should remove deleted items which have not yet been saved", ->
            blog = new Blog
                title: "blog title"
                blog_posts: [
                    { id: 2, content: "example content" },
                    { content: "another post" }
                ]
                
            expected_json =
                title: "blog title"
                blog_posts_attributes: [ id: 2, content: "example content" ]
            
            blog.blog_posts()[1].destroy()
            
            expect( blog.serialize() ).toEqual( expected_json )
            
