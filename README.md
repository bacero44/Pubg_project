## About Pubg project

The PUBG project by Bacero44 consists of consuming the videogame’s API and can show players stats through the webpage and an Arduino device.

This is the first part; consume API and process the data then show in JSON or HTML. This doesn’t contain a final webpage due the final will be created independently with Vue.js, with the only intention of practicing and getting some experience starting from a little idea and obviously winner winner chicken diner!.

# PUBG STATS (BACKEND)

## Features
- Get player data from [PUBG API](https://developer.pubg.com/)
- Make an AVG of season stats and time life
- Show stats in JSON or HTML according to route 
- Keep in memory the latest info

## Limits or challenges 

- 10 RPM (Requests per minute ).
- Works in a simple instance, without persistence, only memory or cache.
- Can’t use Redis in the free version of Heroku 

## Tech
- Ruby / Sinatra
- Redis / RedisJSON
- JSON
- HTML
- SCSS / CSS

## Getting Started

This is an example of how to run a developer environment.

### Prerequisites
* Installed Ruby 
    ```sh 
    Ruby -v
    ```
* Bundle
    ```sh 
    gem install bundler
    ```
* Get a [PUBG API](https://developer.pubg.com/) key.
* Optional: Redis with [RedisJSON](https://redis.io/modules) module.

### Run

1. Clone 
    ```sh 
    https://github.com/bacero44/Pubg_project.git
    ```
2. Install gems 
    ```sh
    bundle install
    ```
3. If you want to use dotenv ( https://rubygems.org/gems/dotenv ), you have to create .env file and put it environment variables: PUBG_API_KEY and REDIS_PASS with its respective value. Otherwise, run Sinatra with at least PUBG_API_KEY.
4. Run 
    ```sh
    ruby app.rb
    ```
5. Enjoy it 

### Usage
- ##### Follow your heart…

