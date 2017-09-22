import twitter
import time

api = twitter.Api(consumer_key="...",
                  consumer_secret="...",
                  access_token_key="...",
                  access_token_secret="...")


done = False
delay = 5*60 #5 minutes delay
tweet_id = {}
retweeted = []

class dummy:
        def __init__(self):
                self.id = None

def mostPopularTweet(tweet_list):
	val = 0
	ret = dummy()
	for tweet in tweet_list:
                tmp = tweet.retweet_count+2*tweet.favorite_count
		if tmp >= val:
			ret = tweet
			val = tmp
	return ret.id

with open("save.dat", "r") as f:
	for line in f:
		tweet_id[line.split(";")[0]]=int(line.split(";")[1].strip("\n"))
	print("loaded data")
with open("retweeted.dat", "r") as f:
        for line in f:
                if line:
                        retweeted.append(int(line.strip("\n")))
        print("loaded retweets")

def save_rt(rt_list):
        with open("retweeted.dat", "w") as f:
                s = ""
                for t in rt_list:
                        s += str(t) + "\n"
                s.rstrip("\n")
                f.write(s)
        print("saved retweets")

while not done:
	last_tweets = []
	for key, value in tweet_id.iteritems():
		last_tweets += api.GetSearch(term=str(key), since_id=value)
		if api.GetSearch(term=str(key), since_id=value):
			tweet_id[key]= api.GetSearch(term=str(key), since_id=value)[-1].id
	selected_tweet = mostPopularTweet(last_tweets)
	if selected_tweet is not None and selected_tweet not in retweeted:
		print("retweeted tweet number {}".format(selected_tweet))
		retweeted.append(selected_tweet)
		save_rt(retweeted)
		print(retweeted)
		api.PostRetweet(selected_tweet)
	with open("save.dat", "w") as f:
		s = ""
		for key, value in tweet_id.iteritems():
			s = s + str(key) + ";" + str(value) + "\n"
		f.write(s)
		print("saved data")
	time.sleep(delay)
