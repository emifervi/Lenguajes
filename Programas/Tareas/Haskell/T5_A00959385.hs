-- isPalindrome
pal :: (Eq a) => [a] -> Bool
pal [] = True
pal [_] = True
pal xs = (head xs == last xs) && (pal(tail(init xs)))

-- comprime
comprime :: (Eq a) => [a] -> [a]
comprime [] = []
comprime (x:xs)
            | length xs == 1 = xs
            | (head xs) == x = comprime xs
            | otherwise = [x] ++ comprime xs

-- eliminaCada
eliminaCadaH :: Int -> [Int] -> Int -> [Int]
eliminaCadaH num (x:xs) cont
                          | length xs == 0 = [x]
                          | num == cont = eliminaCadaH num xs 1
                          | otherwise = [x] ++ eliminaCadaH num xs (cont + 1)

eliminaCada :: Int -> [Int] -> [Int]
eliminaCada _ [] = []
eliminaCada 0 xs = xs
eliminaCada num xs = eliminaCadaH num xs 1

-- rota
rota :: Int -> [Int] -> [Int]
rota _ [] = []
rota 0 xs = xs
rota num xs = rota (num-1) (tail xs ++ [head xs])

-- esPrimo
primeh :: Int -> Int -> Bool
primeh n m
          | (fromIntegral m) > sqrt (fromIntegral n) = True
          | n `mod` m == 0 = False
          | otherwise = (primeh n (m + 1))

isPrime :: Int -> Bool
isPrime n
        | n <= 1 = True
        | otherwise = primeh n 2

-- altitud
data Tree a = Node (Tree a) a (Tree a) | Empty deriving (Show, Eq)

height :: Tree a -> Int
height Empty = 0
height (Node left _ right) = 1 + max (height left) (height right)

-- leafNodes
leafNodes :: Tree a -> Int
leafNodes (Empty) = 0
leafNodes (Node Empty _ Empty) = 1
leafNodes (Node left _ right) = leafNodes left + leafNodes right