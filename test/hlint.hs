module Main where

import Control.Monad
import Language.Haskell.HLint3 (hlint)
import System.Directory
import System.Exit (exitFailure, exitSuccess)
import System.FilePath.Find
import System.FilePath

main :: IO ()
main = do
  pwd <- getCurrentDirectory
  let runHlint f = hlint $ f:
        [ "--ignore=Redundant do"
        , "--ignore=Use camelCase"
        , "--ignore=Redundant $"
        , "--ignore=Use &&"
        , "--ignore=Use &&&"
        , "--ignore=Use const"
        , "--ignore=Use >=>"
        , "--ignore=Use ."
        , "--ignore=Use unless"
        , "--cpp-define=USE_TEMPLATE_HASKELL"
        ]
      recurseInto = and <$> sequence
        [ fileType ==? Directory
        , fileName /=? ".git"
        ]
      matchFile = and <$> sequence
        [ extension ==? ".hs"
        , let notElem' = liftOp notElem
          in filePath `notElem'` filePathExceptions pwd
        ]
  files <- find recurseInto matchFile pwd
  ideas <- fmap concat $ forM files $ \f -> do
    putStr $ "linting file " ++ drop (length pwd + 1) f ++ "... "
    runHlint f
  if null ideas then exitSuccess else exitFailure

filePathExceptions :: FilePath -> [FilePath]
filePathExceptions pwd = map (pwd </>) $
  [ "src/Data/AppendMap.hs" -- parse error when hlint runs
  ]
