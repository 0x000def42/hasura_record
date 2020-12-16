Add link to hasura graphql source

In application.rb run
```
HasuraRecord::Config.configure do |config|
  config.schema = {
    url: https://you.hasura-instance.com,
    secret: "YOU_HASURA_ADMIN_SECRET_KEY"
  }
end
```

Create you model

models/post.rb

```
class Post < HasuraRecord::Base; end
```

- Create -
- Update +
- Delete -
- All +
- Where +
- find +
- find_by +
- limit +
- offcet +
- select +
- associations -
- scopes - (???)