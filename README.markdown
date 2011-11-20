# Tweets Backup 推备图

## Configuration

config/application.rb

```
#config.root_url = "http://%s.windix.org"
config.root_url = "http://%s.lvh.me:3000"
```

## Setup

```
thor tweet_tasks:setup <subdomain>
```

http://<subdomain.URL>/rsync/setup

## Website

```
<subdomain>.windix.org

windix.windix.org <- weird?
moon.windix.org
```

## CLI

```
thor list
```

```
thor tweet_tasks:backup            # backup all
thor tweet_tasks:backup_favorite   # backup my favorites
thor tweet_tasks:backup_mention    # backup my mentions
thor tweet_tasks:backup_timeline   # backup my tweets
thor tweet_tasks:stats             # show statistics
```

## Link

- QQ Open Platform: http://open.t.qq.com
- Sina Open Platform: http://open.weibo.com/apps

