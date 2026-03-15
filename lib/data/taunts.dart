import 'dart:math';

/// Taunt categories for different moods and situations.
enum TauntCategory {
  sarcastic,
  motivational,
  guiltTrip,
  funny,
  harsh,
  gentle,
}

/// A single taunt message with category.
class Taunt {
  final String message;
  final TauntCategory category;
  final String emoji;

  const Taunt({
    required this.message,
    required this.category,
    required this.emoji,
  });
}

/// All built-in taunts organized by category.
class TauntBank {
  static final _random = Random();

  static const List<Taunt> allTaunts = [
    // ══════════════════════════════════════
    //  SARCASTIC (15)
    // ══════════════════════════════════════
    Taunt(message: "Oh look, Mr. 'I'll study later' is here again.", category: TauntCategory.sarcastic, emoji: "😏"),
    Taunt(message: "Back so soon? Your self-control is really something.", category: TauntCategory.sarcastic, emoji: "🙄"),
    Taunt(message: "Wow, that lasted long. New personal record?", category: TauntCategory.sarcastic, emoji: "👏"),
    Taunt(message: "Your discipline just filed a missing persons report.", category: TauntCategory.sarcastic, emoji: "🕵️"),
    Taunt(message: "If procrastination was a sport, you'd be MVP.", category: TauntCategory.sarcastic, emoji: "🏆"),
    Taunt(message: "Oh, you're back. What a completely unexpected surprise.", category: TauntCategory.sarcastic, emoji: "😮"),
    Taunt(message: "Let me guess — 'just one quick peek', right?", category: TauntCategory.sarcastic, emoji: "🤔"),
    Taunt(message: "Your focus session called. It wants its dignity back.", category: TauntCategory.sarcastic, emoji: "📞"),
    Taunt(message: "And the award for shortest focus ever goes to... YOU!", category: TauntCategory.sarcastic, emoji: "🎬"),
    Taunt(message: "I blocked this app for a reason. Remember? No? Figures.", category: TauntCategory.sarcastic, emoji: "🤷"),
    Taunt(message: "The audacity to try again... I admire the confidence.", category: TauntCategory.sarcastic, emoji: "💅"),
    Taunt(message: "You set the goal yourself. Just saying.", category: TauntCategory.sarcastic, emoji: "📝"),
    Taunt(message: "Your willpower has left the group chat.", category: TauntCategory.sarcastic, emoji: "💬"),
    Taunt(message: "Plot twist: the real distraction was you all along.", category: TauntCategory.sarcastic, emoji: "🎭"),
    Taunt(message: "Interesting strategy — set goals then immediately ignore them.", category: TauntCategory.sarcastic, emoji: "🧠"),

    // ══════════════════════════════════════
    //  MOTIVATIONAL (15)
    // ══════════════════════════════════════
    Taunt(message: "You're stronger than this temptation. Keep going!", category: TauntCategory.motivational, emoji: "💪"),
    Taunt(message: "The best version of you is on the other side of discipline.", category: TauntCategory.motivational, emoji: "⭐"),
    Taunt(message: "This moment of resistance is building your character.", category: TauntCategory.motivational, emoji: "🌟"),
    Taunt(message: "Future you will thank present you. Stay strong.", category: TauntCategory.motivational, emoji: "🙏"),
    Taunt(message: "Champions are made in the moments nobody is watching.", category: TauntCategory.motivational, emoji: "🏅"),
    Taunt(message: "Every 'no' to distraction is a 'yes' to your dreams.", category: TauntCategory.motivational, emoji: "🎯"),
    Taunt(message: "You didn't come this far to only come this far.", category: TauntCategory.motivational, emoji: "🚀"),
    Taunt(message: "Discipline is choosing between what you want now vs. what you want most.", category: TauntCategory.motivational, emoji: "💎"),
    Taunt(message: "Small victories lead to massive success. Win this moment.", category: TauntCategory.motivational, emoji: "🏆"),
    Taunt(message: "Your goals deserve your full attention. You got this!", category: TauntCategory.motivational, emoji: "🔥"),
    Taunt(message: "Greatness requires sacrifice. This is your moment.", category: TauntCategory.motivational, emoji: "👑"),
    Taunt(message: "The discomfort you feel now is the price of growth.", category: TauntCategory.motivational, emoji: "🌱"),
    Taunt(message: "Stay locked in. Your breakthrough is closer than you think.", category: TauntCategory.motivational, emoji: "🔒"),
    Taunt(message: "One more hour of focus can change your entire trajectory.", category: TauntCategory.motivational, emoji: "📈"),
    Taunt(message: "You're not just studying. You're building your empire.", category: TauntCategory.motivational, emoji: "🏗️"),

    // ══════════════════════════════════════
    //  GUILT TRIP (15)
    // ══════════════════════════════════════
    Taunt(message: "Your parents didn't sacrifice everything for you to scroll reels.", category: TauntCategory.guiltTrip, emoji: "😢"),
    Taunt(message: "Remember why you started. Don't disrespect your own goals.", category: TauntCategory.guiltTrip, emoji: "💔"),
    Taunt(message: "Your dream life isn't going to build itself while you scroll.", category: TauntCategory.guiltTrip, emoji: "🏚️"),
    Taunt(message: "Someone right now is working on the same dream with zero breaks.", category: TauntCategory.guiltTrip, emoji: "😤"),
    Taunt(message: "Every wasted minute is borrowed from your future happiness.", category: TauntCategory.guiltTrip, emoji: "⏰"),
    Taunt(message: "Your yesterday self would be disappointed right now.", category: TauntCategory.guiltTrip, emoji: "😞"),
    Taunt(message: "That app isn't going to help you pass your exams.", category: TauntCategory.guiltTrip, emoji: "📚"),
    Taunt(message: "You made a promise to yourself. Don't break it.", category: TauntCategory.guiltTrip, emoji: "🤝"),
    Taunt(message: "The people who believe in you are counting on your focus.", category: TauntCategory.guiltTrip, emoji: "👨‍👩‍👧"),
    Taunt(message: "While you're here, your competition is grinding.", category: TauntCategory.guiltTrip, emoji: "⚡"),
    Taunt(message: "Is this really who you want to be? Think about it.", category: TauntCategory.guiltTrip, emoji: "🪞"),
    Taunt(message: "You wrote the goal. You set the timer. Own it.", category: TauntCategory.guiltTrip, emoji: "✍️"),
    Taunt(message: "Your screen time report is already embarrassing. Don't add to it.", category: TauntCategory.guiltTrip, emoji: "📊"),
    Taunt(message: "Success isn't scrolling. Go back to what matters.", category: TauntCategory.guiltTrip, emoji: "🎯"),
    Taunt(message: "The only person you're cheating is yourself.", category: TauntCategory.guiltTrip, emoji: "🃏"),

    // ══════════════════════════════════════
    //  FUNNY (15)
    // ══════════════════════════════════════
    Taunt(message: "This app is more blocked than your ex.", category: TauntCategory.funny, emoji: "😂"),
    Taunt(message: "Nice try, but I'm the bouncer and you're not on the list.", category: TauntCategory.funny, emoji: "🚫"),
    Taunt(message: "Error 404: Your productivity not found. Please try harder.", category: TauntCategory.funny, emoji: "🤖"),
    Taunt(message: "I've seen snails with more self-control. Just saying.", category: TauntCategory.funny, emoji: "🐌"),
    Taunt(message: "Even my grandma focuses better than you. And she's 90.", category: TauntCategory.funny, emoji: "👵"),
    Taunt(message: "If focus was money, you'd be bankrupt right now.", category: TauntCategory.funny, emoji: "💸"),
    Taunt(message: "You vs. your phone addiction: Score 0-47.", category: TauntCategory.funny, emoji: "📱"),
    Taunt(message: "Your attention span and a goldfish are having a competition. The fish is winning.", category: TauntCategory.funny, emoji: "🐟"),
    Taunt(message: "Breaking news: Local student caught trying to access blocked app. Again.", category: TauntCategory.funny, emoji: "📰"),
    Taunt(message: "Achievement unlocked: World's Fastest Goal Abandoner!", category: TauntCategory.funny, emoji: "🎮"),
    Taunt(message: "Loading productivity... ERROR. User keeps opening distractions.", category: TauntCategory.funny, emoji: "⚠️"),
    Taunt(message: "DENIED! Come back when you've finished your work.", category: TauntCategory.funny, emoji: "🛑"),
    Taunt(message: "Your willpower has disconnected from the server.", category: TauntCategory.funny, emoji: "📡"),
    Taunt(message: "The app you're looking for is in another castle. Mario would focus.", category: TauntCategory.funny, emoji: "🍄"),
    Taunt(message: "Knock knock. Who's there? Not this app during focus time.", category: TauntCategory.funny, emoji: "🚪"),

    // ══════════════════════════════════════
    //  HARSH REALITY (12)
    // ══════════════════════════════════════
    Taunt(message: "Every second you waste here is a second your competitor is winning.", category: TauntCategory.harsh, emoji: "⚔️"),
    Taunt(message: "Nobody cares about your excuses. Results matter. Get back to work.", category: TauntCategory.harsh, emoji: "💀"),
    Taunt(message: "You're not special enough to skip the hard work. Nobody is.", category: TauntCategory.harsh, emoji: "🗿"),
    Taunt(message: "Mediocrity is a choice. You're choosing it right now.", category: TauntCategory.harsh, emoji: "📉"),
    Taunt(message: "Your dream requires 100%. You're giving maybe 30%.", category: TauntCategory.harsh, emoji: "🔋"),
    Taunt(message: "Talent without discipline is just wasted potential. Don't waste yours.", category: TauntCategory.harsh, emoji: "🗑️"),
    Taunt(message: "The difference between success and failure? Moments exactly like this.", category: TauntCategory.harsh, emoji: "⚖️"),
    Taunt(message: "Stop lying to yourself. You know you should be working.", category: TauntCategory.harsh, emoji: "🤥"),
    Taunt(message: "Your comfort zone is a beautiful place, but nothing grows there.", category: TauntCategory.harsh, emoji: "🏜️"),
    Taunt(message: "Hard work beats talent when talent doesn't work hard.", category: TauntCategory.harsh, emoji: "🔨"),
    Taunt(message: "Wake up. Time doesn't wait, and neither does success.", category: TauntCategory.harsh, emoji: "⏳"),
    Taunt(message: "You'll regret this wasted time. You always do.", category: TauntCategory.harsh, emoji: "😔"),

    // ══════════════════════════════════════
    //  GENTLE REMINDER (12)
    // ══════════════════════════════════════
    Taunt(message: "Hey, take a breath. You committed to this. You got this.", category: TauntCategory.gentle, emoji: "🌸"),
    Taunt(message: "It's okay to feel the urge. Strength is not giving in.", category: TauntCategory.gentle, emoji: "🌊"),
    Taunt(message: "Gently remind yourself why you're doing this. It matters.", category: TauntCategory.gentle, emoji: "💭"),
    Taunt(message: "This craving will pass. Your accomplishment won't.", category: TauntCategory.gentle, emoji: "🌈"),
    Taunt(message: "Just a few more minutes of focus. You're almost there.", category: TauntCategory.gentle, emoji: "🕊️"),
    Taunt(message: "Be kind to yourself, but also be honest. Back to work.", category: TauntCategory.gentle, emoji: "🤗"),
    Taunt(message: "Deep breath. Close this. Return to what matters to you.", category: TauntCategory.gentle, emoji: "🧘"),
    Taunt(message: "You're doing great by trying. Now keep going.", category: TauntCategory.gentle, emoji: "🌻"),
    Taunt(message: "The urge is temporary. Your growth is permanent.", category: TauntCategory.gentle, emoji: "🌿"),
    Taunt(message: "Hey friend, you set this boundary for a reason. Trust yourself.", category: TauntCategory.gentle, emoji: "💛"),
    Taunt(message: "It's not about perfection, it's about consistency. Stay focused.", category: TauntCategory.gentle, emoji: "✨"),
    Taunt(message: "You're braver than you think. Get back to your goal.", category: TauntCategory.gentle, emoji: "🦁"),
  ];

  /// Get a random taunt from all categories.
  static Taunt getRandomTaunt() {
    return allTaunts[_random.nextInt(allTaunts.length)];
  }

  /// Get a random taunt from a specific category.
  static Taunt getRandomFromCategory(TauntCategory category) {
    final filtered = allTaunts.where((t) => t.category == category).toList();
    if (filtered.isEmpty) return getRandomTaunt();
    return filtered[_random.nextInt(filtered.length)];
  }

  /// Smart taunt selection based on attempt count.
  /// First few attempts = gentle/motivational,
  /// repeated attempts = sarcastic/harsh.
  static Taunt getSmartTaunt(int attemptCount) {
    if (attemptCount <= 1) {
      return getRandomFromCategory(TauntCategory.gentle);
    } else if (attemptCount <= 3) {
      return getRandomFromCategory(TauntCategory.motivational);
    } else if (attemptCount <= 5) {
      final cats = [TauntCategory.sarcastic, TauntCategory.guiltTrip, TauntCategory.funny];
      return getRandomFromCategory(cats[_random.nextInt(cats.length)]);
    } else {
      final cats = [TauntCategory.harsh, TauntCategory.sarcastic, TauntCategory.guiltTrip];
      return getRandomFromCategory(cats[_random.nextInt(cats.length)]);
    }
  }

  /// Get the display name for a category.
  static String categoryName(TauntCategory category) {
    switch (category) {
      case TauntCategory.sarcastic:
        return 'Sarcastic';
      case TauntCategory.motivational:
        return 'Motivational';
      case TauntCategory.guiltTrip:
        return 'Guilt Trip';
      case TauntCategory.funny:
        return 'Funny';
      case TauntCategory.harsh:
        return 'Harsh Reality';
      case TauntCategory.gentle:
        return 'Gentle Reminder';
    }
  }

  /// Get the emoji for a category.
  static String categoryEmoji(TauntCategory category) {
    switch (category) {
      case TauntCategory.sarcastic:
        return '😏';
      case TauntCategory.motivational:
        return '💪';
      case TauntCategory.guiltTrip:
        return '😢';
      case TauntCategory.funny:
        return '😂';
      case TauntCategory.harsh:
        return '💀';
      case TauntCategory.gentle:
        return '🌸';
    }
  }
}
