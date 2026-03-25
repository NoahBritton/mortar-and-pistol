# Mortar and Pistol

## Basic Idea

Medieval era FPS where magic exists, but instead of wands, staffs, and swords, the main characters developed a fleet of wooden/iron modern looking guns that are powered by magic and alchemy. They are sorta like the main heroes of this world and would each identify as one of the X core classes of magic. So far im thinking wizard, witch, alchemist, assassin, and then possibly a ranged beast master or hunter type character, whatever else I come up with.

This could easily be a hero shooter, basic cod type fps, or even a gunfire type rogue-lite with heroes and perks (anything other than a single player story game would take a lot of work, def gonna try to turn it into pvp at some point). Realistically I'll just end up making the characters themselves and a shooting range/playground that I can then pull from once I know how to actually make a game.

---

## Characters / Classes (TBD)

### Wizard
Mid-range abilities and using assault rifles like an AK or an M16. Precision damage and enhancing your guns damage or changing the effects of the bullets, high skill maneuverability, can fall back to recover if you know how to use their kit properly. Emphasis on keeping decent distance between you and your opponent.

### Alchemist (Assault)
Uses a blunderbuss lookin weapon that can be transmuted into different configurations for various uses. Would focus on close range damage and debuffs while bolstering their own health, high skill maneuverability — easy to cover large distances and retreat from engagements but it relies on knowing maps and making sure you place yourself in a favorable position for using your kit.

### Alchemist (Heavy)
Uses a huge wooden launcher that can be filled with various types of flask/potion based ammo. The effects of the ammo depend on the ability you currently have activated or what ammo type you swap to. One good movement ability that has a decently high cooldown, penalizes charging in unprepared.

### Assassin
Uses dual wield light weapons (smg, pistol, something like that) with various wind themed abilities. Very fast and low health, high mobility that is very easy to use. Smoke bombs that remove them from radar and mute their steps for short period of time after entering/leaving the radius.

---

## Unique Abilities / Guns

Emphasis on the use of magical spells or alchemy to enhance the basic functions of your gun(s).

I'd like to have a way for each class or character to have their own unique movement ability that allows for quick repositioning — these would be cast using the guns.

### Movement Abilities

**Wind Boost** — Shooting the guns at the ground to propel yourself. Would be a boost ability (think Jett from Valorant) where the guns (requires dual wield, smgs or pistols) shoot a burst of wind magic out the back and propel you in the direction you are aiming. Possibly this could be swapped between forward and backwards in order to push enemies around (think Lucio).

**Portal Lob** — Lobbing a projectile from the gun and teleporting to where it lands. Kinda boring on its own but maybe you could use it like a portal. Shoot one for the start and one for the destination, you can swap between them like in Portal to close and open portals in different locations. Enemies would not be able to see through them like in Splitgate, you and allies can see through them but cannot shoot through them.

**Grapple Hook** — Grappling hook transmuted from the gun. Could be canceled mid pull to launch yourself (think Widowmaker). Could also be used to drag enemies close; canceling mid drag would release them. If health packs or items exist you could pull those too. Cooldown depends on function used:
- Item pull — short
- Wall pull — medium
- Enemy pull — long

Canceling early cuts cooldown by a percentage (TBD). Items grabbed by the hook are unusable to enemies for a short period (think Sombra hack, maybe poisoned to enemies?) and possible poison debuff given to hooked enemies.

**Potion Rocket Jump** — Shooting a potion shell that splashes and buffs your health and the health of any allies caught in the splash. Would be used by a tank going into a group of enemies to pop an ult or something. Gives knockback to enemies nearby and maybe a short stun but no damage.

### Gun Design Philosophy

Ideally all magic comes from the weapons. This means the weapons have to be tied intrinsically to the kinds of magic they use (i.e., an AK-47 won't be able to use remotely similar magic to a pistol or a submachine gun). The guns themselves would be designed to facilitate the use of its unique magic — they wouldn't just be a basic rifle or pistol.

**Example**: A set of pistols or SMGs that have a sort of vent on either side. The vents would face backwards on the outer sides and forward on the inner sides (refer to Wind Boost above). Wind would burst out either set of vents depending on the state of the ability.

---

## Elemental Affinities (Loadout System)

*Concept by chobsup*

In each loadout slot, you'd pick the attuned element. Primary Weapon, Secondary Weapon, Abilities 1-3 could all have different attunements or all the same — up to the player. "Less" and "more" are determined around the weapon's base damage.

### Fire
- Less damage, faster fire rate
- Deals DoT
- Offensive abilities leave a burning trail when applicable
- Defensive abilities release a damaging shockwave
- Movements are faster
- Healing abilities (if applicable) halt any DoTs currently active

### Earth
- Higher damage, slower reloads
- Projectiles are larger when applicable, and have heavier arcs
- Offensive abilities have larger AoEs when applicable
- Defensive abilities can absorb more damage when applicable
- Movements are slower but give free damage reduction
- Healing abilities heal more, but heal slower

### Lightning
- Faster fire rate, faster reload, armor piercing at 50% reduced damage
- Offensive abilities fire more quickly
- Defensive abilities absorb less damage
- Movements are much faster
- Healing abilities heal less but heal faster

### Wind
- Greatly increased firing speed and reload, lower damage
- Hits **Suffocate** targets, shrouding them in fog and reducing the effectiveness of healing and magic-based effects
- Offensives move faster and are transparent
- Defensives push enemies away
- Movements are much faster and provide slowfall when applicable
- Healing grants a speed boost to the target

### Poison
- Lower damage
- Applies DoT like fire, but faster and *more*
- All abilities release clouds of poison that also inflict this DoT

### Ourple / Cosmic / Void / Whatever
- Slower fire rate, MUCH lower damage (25% reduced)
- Damage inflicted deals no actual damage — instead reduces the target's maximum health
- Max health starts to return after 5s of not taking Ourple damage, fully restores after another 5s
- Offensive abilities have a vacuum effect that sucks enemies in
- Defensive abilities push enemies away
- Movements are replaced with teleports when applicable
- Healing now applies armor (up to 75%), amount applied each tick lowers exponentially as armor rises

### Light
- Slightly lower damage, much faster reloads
- All projectiles are hitscan when applicable
- Movements are teleports when applicable
