# Messages spécifiques à Carcassonne

## Messages

### ELECTS

Format : `id ELECTS role id+`

Le message `ELECTS` permet de donner un rôle à des identifiants. On défini une liste de rôles possibles:  
- `player` : l'identifiant correspond à un joueur (qu'il soit humain ou robot)
- `referee` : l'identifiant correspond à un arbitre
- `spectator` : l'identifiant correspond à un spectateur (affichage pour un public, enregistrement de la partie)
- `utility` : l'identifiant correspond à un programme utilitaire

Un message `ELECTS` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### AGREES

Format : `id AGREES exp_or_var+`

Un joueur peut indiquer les extensions et les variantes qu'il supporte par le message `AGREES`.  
Par exemple, si le joueur Sam supporte les extensions 'Inns & Cathedrals' et 'Traders & Builders' ainsi que la variante blitz, il peut l'indiquer comme ceci : `Sam AGREES inns traders blitz`.  

Un arbitre peut indiquer les extensions et les variantes qui seront utilisées lors de la partie également par le message `AGREES`.  
Par exemple, l'arbitre ARB indique que les extensions 'Inns & Cathedrals' et 'Traders & Builders' ainsi que la variante blitz seron utilisées lors de la partie comme ceci : `ARB AGREES inns traders blitz`.

Un message `AGREES` envoyé par un identifiant de role `spectator` ou `utility` n'a aucun effet.

### PLACES

Format : `id PLACES id' tile x:y` (placement sans meeple)  
`id PLACES id' tile x:y meeple_type meeple_position` (placement avec meeple)

Pour placer une tuile, un joueur doit remettre son identifiant dans le champ `id'` (exemple:  `Sam PLACES Sam f1-c2-f3-c2 2:3 regular f1`)  
Les autres joueurs ne prennent pas en compte un messages PLACES envoyé par un identifiant de type `player`. Ils doivent attendre qu'un arbitre confirme le placement.

Un arbitre confirme le placement d'une tuile d'un joueur en indiquant l'id du joueur dans le champ `id'` (exemple:  `ARB PLACES Sam f1-c2-f3-c2 2:3 regular f1`).  
Quand ils recoivent un message `PLACES` provenant d'un arbitre, les joueurs prennent en compte le placement et modifient leur interface si besoin.

Le champ `tile` doit respecter cette nomenclature : `DB-B-B-B(:A)`.  
`D` correspond à l'orientation de la tuile (`N` : orientation par défaut de la tuile, `W` : rotation de 90° vers la gauche, `E` : rotation de 90° vers la droite, `S` : rotation de 180°).  
`B-B-B-B` correspond au nom par défaut (sans orientation) de la tuile.   
`B` correspond à la description d'un bord de la tuile et possède deux formes : `Zi` ou `ZiViZi`.  
`Z` correspond à une zone (`c` pour une ville, `C` pour une ville avec blason, `f` pour un champ) et `V` correspond à une voie (`r` pour une route).  
`i` correspond à l'identifiant **unique** de la zone ou de la voie. Par exemple `c1` et `c2` sont deux châteaux distincs, c'est-à-dire qu'ils ne sont pas reliés sur la tuile. Toutes les zones et les voies, même de type différent, ne doivent pas partager le même identifiant. Par exemple, la tuile `c1-f2r3f4-f4r3f2-f2` est correcte mais la tuile `c1-f2r1f3-f3r1f2-f2` n'est pas correcte (`c1` et `r1` ne peuvent pas partager le même identifiant car ils sont de types différents).
Enfin `:A` est facultatif et sert à indiquer si une abbaye se trouve sur la tuile.

Les champs `meeple_type` et `meeple_position` correspondent respectivement au type de meeple placé (`regular` pour les meeples du jeu de base) et à la position du meeple sur la tuile (c'est à dire un `Zi`, un `Vi` ou un `A` présent dans le nom de la tuile).

Un message `PLACES` envoyé par un identifiant de role `spectator` ou `utility` n'a aucun effet.

### BLAMES

Format : `id BLAMES id' reason` (donner un blâme à un joueur)  
`id BLAMES amount` (indiquer le nombre de blâme autorisés pour la partie)

Le message `BLAMES` permet de donner un blâme à un identifiant. La raison du blâme est indiquée dans le champ `reason`.
Un arbitre peut mettre un blâme à un joueur qui aurait soit envoyé un message non autorisé (`illegal-message`) soit aurait fait un mauvais placement avec la commande `PLACES`.

Un placement est mauvais si :
- le champ `id'` n'est pas le même que le champ `id` (`illegal-id`),
- Le nom de la tuile ne respecte pas la nomenclature (`illegal-tile`),
- Les coordonées indiquées sont déjà prises par une autre tuile ou ne sont pas collées à une tuile du plateau (`illegal-position`),
- les coordonées sont correctes mais engendre des collisions entre zones de différents types (`illegal-adjacency`),
- le nom du meeple ne correspond pas avec les noms possibles de la partie (jeu de base (`regular`) et éventuelles extensions) (`illegal-meeple-type`),
- la position du meeple ne correspond pas avec une zone, une voie ou une abbaye présente dans le nom de la tuile (`illegal-meeple-position`). 

Dans le cas d'un mauvais placement, l'arbitre ne confirme pas le placement par le message `PLACES` mais donne un blâme au joueur par le message `BLAMES`.

Le message `BLAMES` permet également d'indiquer le nombre de blâme autorisés pour la partie. Par exemple, une partie entre joueurs confirmés pourrait n'autoriser qu'un seul blâme alors qu'une partie entre joueurs novice pourrait autoriser 5 blâmes.

Si un joueur dépasse le nombre de blâmes autorisés, il est alors expulsé de la partie par l'arbitre (message `EXPELS`).

Un message `BLAMES` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### OFFERS

Format : `id OFFERS id' tile`

Afin d'enlever aux joueurs la charge de se souvenir de son tour et de piocher une tuile, l'arbitre s'occupe de cela par le message `OFFERS`. Par exemple, quand c'est au tour du joueur Sam de jouer, l'arbitre ARB envoie `ARB OFFERS Sam f1-c2-f3-c2`.

Un message `OFFERS` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### SCORES

Format : `id SCORES id' points`

Le placement d'une tuile peut avoir comme effet de donner un certain nombre de points à des joueurs.  
L'arbitre s'occupe de calculer les points gagnés par les joueurs à l'issue d'un placement et envoie un ou plusieurs messages `SCORES` en indiquant le joueur concerné et le nombre de points gagnés.

Un message `SCORES` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### COLLECTS

Format : `id COLLECTS id' meeple_type (amount)`

Le placement d'une tuile peut avoir comme effet de redonner à un joueur un ou plusieurs meeple qu'il avait placé.  
L'arbitre s'occupe de déterminer quels joueurs récupèrent des meeples et envoie un ou plusieurs messages `COLLECTS` en indiquant le joueur concerné et le type de meeple récupéré. Un champ facultatif permet d'indiquer un nombre de meeples récupérés. Si le champ n'est pas renseigné, le nombre de meeple récupérés par le joueur est de 1.

Un message `COLLECTS` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### STARTS

Format : `id STARTS`

L'arbitre indique le début de la partie par le message `STARTS`.

Les joueurs commencent tous avec 0 meeple. L'arbitre donne ensuite à chaque joueur des meeples par le message `COLLECTS` (dans le jeu de base chaque joueur reçoit 8 meeples de type `regular`, on pourra penser à une variante de jeu où les joueurs commencent la partie avec moins de meeples).

Enfin l'arbitre lance le premier tour par le message `OFFERS`.

Un message `STARTS` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.

### ENDS

Format : `id ENDS id+`

L'arbitre met fin à la partie par le message `ENDS` et indique l'identifiant du joueur qui a gagné la partie. Dans le cas d'une égalité, l'arbitre indique les identifiants des joueurs qui ont gagné.

Un message `ENDS` envoyé par un identifiant de role `spectator` ou `player` n'a aucun effet.