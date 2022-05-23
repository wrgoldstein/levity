# Levity

Thoughts on how this improves on frivolity and cookie


1. elixir over python
2. sticking to hcl for now
3. state is entirely server side :-o
4. updating metrics is reflected with hot reload [x] !!!
4. ```
  Path.wildcard("metrics/*.*")
  |> Enum.map(&File.read!/1)
  |> Enum.join("\n")
  |> HXL.decode!()
  |> :erlang.term_to_binary()
  |> Base.encode64()
  |> String.length
  ```

5. 