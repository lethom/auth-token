{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE KindSignatures    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

module Servant.Auth.Token.Api where

import           Auth.Token
import           Control.Monad    (mzero)
import           Data.Aeson
import           Data.Proxy
import           Data.Token
import           Data.Token.Aeson
import           GHC.Generics
import           Servant.API

type AuthentApi a = PostTokenGetRoute a
              :<|> PostTokenRefreshRoute

authentApi :: Proxy (AuthentApi a)
authentApi = Proxy

type PostTokenGetRoute a =
    "token"
    :> "get"
    :> ReqBody '[JSON] a
    :> PostCreated '[JSON] AccessGrant

type PostTokenRefreshRoute =
    "token"
    :> "refresh"
    :> ReqBody '[JSON] PostTokenRefreshReq
    :> PostCreated '[JSON] AccessGrant

data PostTokenRefreshReq = PostTokenRefreshReq { refreshToken :: Token "refresh" }
    deriving (Generic)

instance FromJSON PostTokenRefreshReq
instance ToJSON PostTokenRefreshReq

instance ToJSON (EphemeralToken level) where
    toJSON (EphemeralToken time tok) =
      object [ "value"  .= tok
             , "expire" .= time ]

instance FromJSON (EphemeralToken level) where
    parseJSON (Object v) = EphemeralToken <$> v .: "time"
                                          <*> v .: "value"
    parseJSON _ = mzero

instance ToJSON AccessGrant where
    toJSON (AccessGrant acc ref) =
      object [ "access"  .= acc
             , "refresh" .= ref ]

instance FromJSON AccessGrant where
    parseJSON (Object v) = AccessGrant <$> v .: "access"
                                       <*> v .: "refresh"
    parseJSON _ = mzero
