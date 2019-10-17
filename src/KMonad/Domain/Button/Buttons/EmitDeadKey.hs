{-|
Module      : KMonad.Domain.Button.Buttons.EmitDeadKey
Description : A button that emits deadkey encoding macros
Copyright   : (c) David Janssen, 2019
License     : MIT

Maintainer  : janssen.dhj@gmail.com
Stability   : experimental
Portability : non-portable (MPTC with FD, FFI to Linux-only c-code)

-}
module KMonad.Domain.Button.Buttons.EmitDeadKey
  ( mkEmitDeadKey
  , mkEmitDeadKeyM
  )
where

import KMonad.Core
import KMonad.Domain.Effect

-- | Return a button that emits a special symbol on Press (does nothing on Release)
mkEmitDeadKey :: (MonadSymbol m)
  => DeadKey
  -> Button m
mkEmitDeadKey dk = mkButton $ \case
  Engaged   -> emitDeadKey dk
  Disengaged -> pure ()

-- | Return a button that emits a mkEmitDeadKey button from an arbitrary Monad
mkEmitDeadKeyM :: (MonadSymbol m, Monad n)
  => DeadKey
  -> n (Button m)
mkEmitDeadKeyM = pure . mkEmitDeadKey