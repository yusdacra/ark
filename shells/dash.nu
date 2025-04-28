def "main build" [file: path] {
  percli dac build -f ($file | path basename)
  glob ./built/*
    | enumerate
    | each {
      |f| mv -f $f.item (
            $env.PWD
            | path join .. provision (
              $f.item
                | path basename
                | str replace "_output.yaml" ".yaml"
                | $"9($f.index)-($in)"
              )
          )
      }
  rm ./built
}

def main [] {}