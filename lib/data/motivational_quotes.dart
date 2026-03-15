import 'dart:math';

/// Motivational quotes shown on the home screen dashboard.
class MotivationalQuotes {
  static final _random = Random();

  static const List<String> quotes = [
    "The secret of getting ahead is getting started. — Mark Twain",
    "Focus on being productive instead of busy. — Tim Ferriss",
    "It's not that I'm so smart, it's just that I stay with problems longer. — Albert Einstein",
    "The successful warrior is the average man, with laser-like focus. — Bruce Lee",
    "Discipline is the bridge between goals and accomplishment. — Jim Rohn",
    "You will never always be motivated. You have to learn to be disciplined.",
    "Small daily improvements over time lead to stunning results. — Robin Sharma",
    "The only way to do great work is to love what you do. — Steve Jobs",
    "Don't count the days, make the days count. — Muhammad Ali",
    "Your future is created by what you do today, not tomorrow. — Robert Kiyosaki",
    "Action is the foundational key to all success. — Pablo Picasso",
    "Excellence is not a destination but a continuously growing thing.",
    "The difference between ordinary and extraordinary is that little extra.",
    "What you do today can improve all your tomorrows. — Ralph Marston",
    "Believe you can and you're halfway there. — Theodore Roosevelt",
    "It always seems impossible until it's done. — Nelson Mandela",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Push yourself, because no one else is going to do it for you.",
    "Great things never come from comfort zones.",
    "Don't wish it were easier. Wish you were better. — Jim Rohn",
    "Success is the sum of small efforts repeated day in and day out. — Robert Collier",
    "The pain you feel today will be the strength you feel tomorrow.",
    "Fall seven times, stand up eight. — Japanese Proverb",
    "Hustle in silence and let your success make the noise.",
    "Work hard in silence, let success be your noise. — Frank Ocean",
    "The mind is everything. What you think, you become. — Buddha",
    "Stay focused, go after your dreams, and keep moving toward your goals.",
    "A little progress each day adds up to big results.",
    "Your limitation — it's only your imagination.",
    "Strive for progress, not perfection.",
    "Dream it. Wish it. Do it.",
    "Don't stop when you're tired. Stop when you're done.",
    "Wake up with determination. Go to bed with satisfaction.",
    "Do something today that your future self will thank you for.",
    "The key to success is to focus on goals, not obstacles.",
    "Hard work beats talent when talent doesn't work hard. — Tim Notke",
    "Success doesn't just find you. You have to go out and get it.",
    "Doubt kills more dreams than failure ever will. — Suzy Kassem",
    "Don't be afraid to give up the good to go for the great. — John D. Rockefeller",
    "I find that the harder I work, the more luck I seem to have. — Thomas Jefferson",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "You don't have to be great to start, but you have to start to be great. — Zig Ziglar",
    "Success is not final, failure is not fatal: it is the courage to continue that counts. — Winston Churchill",
    "Perseverance is not a long race; it is many short races one after the other. — Walter Elliot",
    "Be so good they can't ignore you. — Steve Martin",
    "Quality is not an act, it is a habit. — Aristotle",
    "The only impossible journey is the one you never begin. — Tony Robbins",
    "Opportunities don't happen. You create them. — Chris Grosser",
    "Everything you've ever wanted is on the other side of fear. — George Addair",
    "Productivity is never an accident. It is always the result of intelligent effort. — Paul J. Meyer",
  ];

  /// Get the quote of the day (changes daily based on date).
  static String getQuoteOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  /// Get a random quote.
  static String getRandomQuote() {
    return quotes[_random.nextInt(quotes.length)];
  }
}
