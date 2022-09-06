# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Rumbl.Multimedia

categories = ["Action", "Drama", "Romance", "Comedy", "Sci-fi"]

for category <- categories do
  Multimedia.create_category!(category)
end
