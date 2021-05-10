module KMonad.KeyIO.Linux.Types
  ( Keycode(..)
  , GetKey, PutKey
  , RawEvent(..), HasRawEvent(..), mkRaw, mkSync
  , keyNames, keyAliases
  , EvType(..), _EvType
  , module KMonad.KeyIO.Common.Types
  )

where


import KMonad.Prelude
import KMonad.Util.Name
import KMonad.Util.Time
import KMonad.Util.Unsorted
import KMonad.KeyIO.Common.Types

import qualified RIO.HashMap as M

--------------------------------------------------------------------------------
-- $keycode

-- | In Linux we use 'Word16', the linux-native keycode type
--
-- NOTE:
-- * Required by KMonad.App: Eq, Show, Hashable
-- * Used to keep a set in Evdev: Ord
-- * Used to specify keycodes as numbers and ranges: Num, Enum
newtype Keycode = Keycode { unKeycode :: Word16 }
  deriving (Eq, Ord, Num, Show, Enum, Hashable)

type GetKey = GetKey_ Keycode
type PutKey = PutKey_ Keycode

--------------------------------------------------------------------------------
-- $raw

-- | The RawEvent datatype
--
-- Linux produces a stream of binary data representing all its input events
-- through the \/dev\/input files. Each event is represented by 5 numbers:
-- seconds, microseconds, event-type, event-code, and event-value. For more
-- explanation look at: https://www.kernel.org/doc/Documentation/input/input.txt
--
-- We parse the entire event, but discard everything except the keycode.
data RawEvent = RawEvent
  { _leS    :: !Word64  -- ^ The seconds component of system time
  , _leNS   :: !Word64  -- ^ The nanoseconds component of system time
  , _leType :: !Word16  -- ^ The type signals the kind of event (we only use EV_KEY)
  , _leCode :: !Word16  -- ^ The keycode indentifier of the key
  , _leVal  :: !Int32   -- ^ Whether a press, release, or repeat event
  } deriving (Show)
makeClassy ''RawEvent

-- | Generate a new raw event
mkRaw :: MonadIO m => IsPress -> Keycode -> m RawEvent
mkRaw p c = do
  t <- getCurrentSystemTime
  pure $ RawEvent
    { _leS    = fi $ t^._s
    , _leNS   = fi $ t^._ns
    , _leType = 1
    , _leCode = unKeycode c
    , _leVal  = if p then 1 else 0
    }

-- | Generate a new sync event
mkSync :: MonadIO m => m RawEvent
mkSync = do
  t <- getCurrentSystemTime
  pure $ RawEvent
    { _leS    = fi $ t^._s
    , _leNS   = fi $ t^._ns
    , _leType = 0
    , _leCode = 0
    , _leVal  = 0
    }

--------------------------------------------------------------------------------

data EvType = Release | Press | Repeat deriving (Eq, Ord, Enum, Show)

_EvType :: Prism' Int32 EvType
_EvType = prism' (fi . fromEnum) $ \i -> ([Release, Press, Repeat] ^? ix (fi i))


--------------------------------------------------------------------------------
-- $names

z :: [a] -> [b] -> [(b, a)]
z = flip zip

-- | Map of standard names to linux keycodes
keyNames :: NameMap Keycode
keyNames = M.fromList $
  z [1..83]
    [ "esc", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" , "-" , "="
    , "bspc", "tab", "q", "w", "e", "r", "t", "y", "u" , "i", "o" , "p", "["
    , "]", "ret", "lctl", "a", "s", "d", "f" , "g", "h", "j" , "k", "l", ";"
    , "'", "`", "lsft", "\\", "z" , "x", "c", "v", "b" , "n", "m", ",", ".", "/"
    , "rsft", "kp*" , "lalt", "spc", "caps" , "f1", "f2", "f3", "f4", "f5", "f6"
    , "f7", "f8", "f9", "f10" , "num", "scrl", "kp7", "kp8", "kp9" , "kp-"
    , "kp4", "kp5", "kp6" , "kp+", "kp1", "kp2", "kp3", "kp0" , "kp."] <>
  z [85..120]
    [ "zenk", "102d", "f11", "f12", "ro", "kata", "hira", "henk", "kahi"
    , "muhe", "kpj,", "kprt", "rctl", "kp/", "ssrq", "ralt", "feed", "home"
    , "up", "pgup", "left", "rght", "end", "down", "pgdn", "ins", "del", "macr"
    , "mute", "vold", "volu", "pwr", "kp=", "kp+-", "paus", "scl"
    ] <>
  z [121..182]
    [ "kp,", "hang", "hanj", "yen", "lmet", "rmet", "cmps", "stop", "agn"
    , "prps", "undo", "frnt", "copy", "open", "past", "find", "cut", "help"
    , "menu", "calc", "setp", "slp", "wake", "file", "send", "delf", "xfer"
    , "prg1", "prg2", "www", "msds", "coff", "scnl", "rot", "dir", "cycl"
    , "mail", "book", "comp", "back", "fwd", "clcd", "ejct", "eccd", "nxsg"
    , "plps", "prvs", "stcd", "rec", "rew", "phon", "iso", "cfg", "hmpg", "refr"
    , "exit", "move", "edit", "scup", "scdn", "kp(", "kp)", "new", "redo" ] <>
  z [183..194]
    [ "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20", "f21", "f22"
    , "f23", "f24"] <>
  z [200..248]
    [ "plcd", "pscd", "prg3", "prg4", "dash", "susp", "cls", "play", "ffwd"
    , "bass", "prnt", "hp", "cmra", "soun", "ques", "emal", "chat", "srch"
    , "conn", "fina", "sprt", "shop", "alte", "cncl", "brdn", "brup", "medi"
    , "svid", "kbtg", "kbdn", "kbup", "ksnd", "repl", "fwml", "save", "docs"
    , "batt", "blue", "wlan", "uwb", "unkn", "vdnx", "vdpv", "brcc", "brau"
    , "doff", "wwan", "wmax", "rfkl", "mcmu" ]

keyAliases :: [Alias]
keyAliases = []
