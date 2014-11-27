## Using an API in a Sinatra app

### SETUP:

1. **Pick an API.**  Some good ones:  Rotten Tomatoes, Yelp, Spotify.  You can also check out sites like [apis.io](http://apis.io/) to find fun APIs.
2. **Review the documentation for your API.**
  - What data does it provide you? If you're looking at the Spotify API, for example, how would I get a list of all the songs? What attributes about each song does it provide? [**NOTE:** You can practice getting data from the API using the `curl` command on the command line.]
  - Does the API serve up JSON or XML?
  - Does the API cost money? Does it have a limit on the number of requests you can make per day?
  - Do I need an API key to access the data?
    - If so, set up an account to get your key(s).
    - How do I pass my keys to the API when I make a request? (Some APIs, such as the Beer Mapping API we'll use, allow you to pass the key directly into the URL, while others require you to pass it via the request header.)

3. **Pick a library to query your API.**  Ruby has the [Net::HTTP](http://ruby-doc.org/stdlib-2.1.5/libdoc/net/http/rdoc/Net/HTTP.html) library, but I'd recommend using a gem like [HTTParty](https://github.com/jnunemaker/httparty) (which I'll use here) or [Faraday](https://github.com/lostisland/faraday).
  - HTTParty has some nice [example apps](https://github.com/jnunemaker/httparty/tree/master/examples).

### BUILDING THE APP:
* **Set your keys.** If you need keys to access the API, use the `dotenv` gem to load your keys. (That way, you're not hardcoding your secret credentials into your app.)
  1. After creating your git repo, create a `.gitignore` file to ignore the `.env` file that we'll create to store your API credentials.

    ```no-highlight
    # create your git repo
    $ git init

    # create the .gitignore file & add .env to it
    $ echo .env > .gitignore

    # commit your changes
    $ git add -A && git commit -m "Add .env to .gitignore"
    ```

    **This step is important!!!** It is very easy to expose your secret credentials on GitHub if you forget to gitignore your `.env` file, or if you gitignore it after creating the file and committing it once. When your keys are attached to credit card information, nefarious bots can grab your credentials off of GitHub and rack up massive bills on services like AWS.

  2. Create the `.env` file and add your keys. For our [Beer Mapping API](http://beermapping.com/api/), we need a single API key.  (Some apps will provide you an ID and a key.)

    ```no-highlight
    # .env
    BEER_MAPPING_API_KEY=<your_api_key>
    ```

    Using the `dotenv` gem, we'll be able to reference this API key inside of our app like so:

    ```ruby
    ENV['BEER_MAPPING_API_KEY']
    ```

  3. Create a `.env.example` file that lists the *name(s)* of any API keys (or other credentials) that your app uses, but does *not* include your actual API key.

    ```no-highlight
    # .env.example
    BEER_MAPPING_API_KEY=
    ```

    This tells other developers who clone your app that they'll need to add their own Beer Mapping API key to the app to make it work.  They can create their own `.env` file and input their key there.

  3. Require the `dotenv` gem in your `app.rb` file.  To get access to the credentials we stored in the `.env` file, we need to require the `dotenv` gem and call `Dotenv.load`.

    ```ruby
    # app.rb
    require 'sinatra'
    require 'dotenv'

    Dotenv.load

    # ...

    ```
* **Use HTTParty to query the API.** The HTTParty gem provides an `HTTParty` class with class methods like `.get` and `.post` that we can use to make HTTP requests to an API from our app.

    ```ruby
    # app.rb
    require 'sinatra'
    require 'dotenv'

    # require the gem
    require 'httparty'

    Dotenv.load

    # test out the API - get breweries in/near Boston
    city = "Boston"
    state = "MA"

    city_response = HTTParty.get("http://beermapping.com/webservice/locquery/#{ENV['BEER_MAPPING_API_KEY']}/#{city}")
    state_response = HTTParty.get("http://beermapping.com/webservice/locstate/#{ENV['BEER_MAPPING_API_KEY']}/#{state}")
    ```

    If I put a `binding.pry` after hitting the API, I can check out what my response variables look like and write methods to retrieve the information I want for various pages on my app.

    For example, say I want to allow a user to search for breweries by city on the breweries index page:

    ```ruby
    # app.rb
    # ...

    def city_search(city)
      response = HTTParty.get("http://beermapping.com/webservice/locquery/#{ENV['BEER_MAPPING_API_KEY']}/#{city}")

      # return an array of brewery hashes from the response we got
    end

    get '/breweries' do
      if params[:city]
        # we need to escape spaces, etc., in user input before passing it in the URL
        city = URI.encode(params[:city])
        @breweries = city_search(city)
      else
        # return breweries in Boston if no search term
        @breweries = city_search("Boston")
      end

      erb :'breweries/index'
    end
    ```
    ```html
    <!-- views/breweries/index.erb -->

    <h3>Search breweries by city:</h3>

    <form method="get" action="/breweries">
      <input type="text" name="city">
      <input type="submit" value="Search">
    </form>
    ```
