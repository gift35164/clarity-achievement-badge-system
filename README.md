# Gaming Achievement Platform - Badge System for In-Game Milestones

## Overview
The **Gaming Achievement Platform** is a decentralized smart contract built on the blockchain, designed to create, manage, and track achievement badges for in-game milestones. This contract allows players to mint, transfer, update, and burn badges based on their gaming accomplishments. It also ensures secure ownership and access control through non-fungible tokens (NFTs).

With this platform, badges are minted as unique, non-transferable tokens that represent in-game achievements. Badges can be issued for milestones like leveling up, completing a challenge, or earning special rewards within the game. Each badge is linked to a unique URI containing metadata about the achievement.

## Features
- **Minting Achievements**: Players can mint single or batch achievement badges by specifying a URI, with validation of the URI's length and format.
- **Badge Ownership**: Only the badge owner can burn or transfer the badge.
- **Burning Badges**: Badges can be burned (revoked) to signify the loss or removal of an achievement.
- **Batch Minting**: Allows the minting of multiple badges in a single transaction to reduce gas costs and streamline the process for large-scale gaming systems.
- **Metadata Management**: Update badge URIs to reflect changes in the associated achievement details.
- **Burned Badge Status**: Track and prevent operations on badges that have been burned.

## Error Codes
- `err-owner-only`: Error if the caller is not the badge owner.
- `err-not-badge-owner`: Error if the caller does not own the badge.
- `err-badge-exists`: Error if the badge already exists.
- `err-badge-not-found`: Error if the badge is not found.
- `err-invalid-uri`: Error if the URI provided is invalid.
- `err-already-burned`: Error if the badge has already been burned.

## Data Structures
- **Achievement Badge**: Non-fungible token (NFT) representing a unique badge.
- **Last Badge ID**: Tracks the latest badge ID issued.
- **Badge URI Map**: Maps badge IDs to their respective URI (metadata).
- **Burned Badges Map**: Tracks the burned status of badges.

## Contract Functions

### Public Functions
- **mint-achievement-badge(uri)**: Mints a single badge with a provided URI representing a gaming achievement.
- **batch-mint-achievements(uris)**: Mints a batch of achievement badges by providing a list of URIs.
- **burn-achievement-badge(badge-id)**: Burns a specific badge, revoking the achievement from the user.
- **transfer-achievement-badge(badge-id, recipient)**: Transfers a badge to another user, allowing achievement ownership to change.
- **update-achievement-uri(badge-id, new-uri)**: Updates the URI of a badge, reflecting changes to its metadata.

### Read-Only Functions
- **get-achievement-uri(badge-id)**: Retrieves the URI (metadata) associated with a specific badge.
- **get-achievement-owner(badge-id)**: Retrieves the owner of a specific badge.
- **get-last-achievement-id()**: Returns the ID of the last minted badge.
- **is-achievement-burned(badge-id)**: Checks whether a badge has been burned.

## Usage

### Minting a Single Achievement Badge
```clojure
(mint-achievement-badge "https://example.com/achievement/1")
```

### Minting Multiple Achievement Badges
```clojure
(batch-mint-achievements ["https://example.com/achievement/1" "https://example.com/achievement/2"])
```

### Burning an Achievement Badge
```clojure
(burn-achievement-badge 1)
```

### Transferring an Achievement Badge
```clojure
(transfer-achievement-badge 1 "SP3XxK6y1Bo1Z3T3QWCVgEwPZZv8FSFP2jj3JG7K")
```

### Updating the URI of an Achievement Badge
```clojure
(update-achievement-uri 1 "https://new-url.com/achievement/1")
```

### Checking if a Badge has been Burned
```clojure
(is-achievement-burned 1)
```

## Installation

To interact with this contract, you can use a compatible blockchain development framework such as **Clarity** for smart contract development on the Stacks blockchain.

## Security Considerations
- **Ownership Validation**: All functions that modify or transfer badges are restricted to the badge owner.
- **URI Validation**: Ensures that badge URIs are within the allowed length and format.
- **Burn Prevention**: Prevents operations on burned badges.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing
We welcome contributions! Please fork this repository, create a branch for your feature or fix, and submit a pull request.
