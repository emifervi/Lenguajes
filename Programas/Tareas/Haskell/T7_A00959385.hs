-- Triangulo de pascal
siguiente :: [[Int]] -> [Int]
siguiente [] = [1]
siguiente triangle = [1] ++ (zipWith (+) (last triangle) (tail(last triangle))) ++ [1]

-- Cambios
cambios :: [Int] -> [Int]
cambios [] = []
cambios (x:xs)
          | length xs == 0 = []
          | x == (head xs) = cambios xs
          | otherwise = [x] ++ cambios xs

-- Muy ordenados
muyOrdenados :: [Int] -> Bool
muyOrdenados [] = False
muyOrdenados (x:xs)
          | length xs == 1 = True
          | (x > 0) && ((head xs) >= (2*x)) = muyOrdenados xs
          | (x < 0) && ((head xs) >= (x `div` 2)) = muyOrdenados xs
          | otherwise = False

-- El camino
-- camino :: Int -> Int -> [(Int, Int)] -> [[(Int, Int)]]
