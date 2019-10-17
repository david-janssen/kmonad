{-|
Module      : KMonad.Domain.Button.Buttons.LayerRem
Description : A button that adds a layer to the top of the stack
Copyright   : (c) David Janssen, 2019
License     : MIT

Maintainer  : janssen.dhj@gmail.com
Stability   : experimental
Portability : non-portable (MPTC with FD, FFI to Linux-only c-code)

Permanently remove a layer from the stack

-}
module KMonad.Domain.Button.Buttons.LayerRem
  ( mkLayerRem
  , mkLayerRemM
  )
where

import KMonad.Core
import KMonad.Domain.Effect

mkLayerRem :: (MonadTrace m, MonadStackManip m)
  => Name -- ^ The ID of the layer to add to the stack
  -> Button m
mkLayerRem lid = mkButton $ \case
  Engaged   -> trace ("popping layer: " <> lid) >> popL lid
  Disengaged -> pure ()

mkLayerRemM :: (MonadTrace m, MonadStackManip m, Monad n)
  => Name -- ^ The ID of the layer to remove from the stack
  -> n (Button m)
mkLayerRemM = pure . mkLayerRem