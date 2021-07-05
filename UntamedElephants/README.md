This code was made by me following ERC721 from @OpenZeppelin standards.

I was hired to develop this code to follow specific requirements
- For one, to make users mint their own tokens at an specific date
- Make the mint cost 0.06 ETH per token
- 7500 tokens as the totalsupply
- Create a single run function that allows the owner to mint 55 with out any cost apart from gas and gets disabled to be run again
- Make mints limited to 10 mints per transaction (cost applies eg. 10 mints = 0.06 ETH * 10)
- And lastly a function to retrieve all the ETH balance of the contract to the _owner
