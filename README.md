<p align="center">
    <img 
        src="https://user-images.githubusercontent.com/1342803/59051613-4dca0f00-885b-11e9-8ed7-509eacdf8f1c.png" 
        height="64" 
        alt="Fluent"
    >
    <br>
    <br>
    <a href="https://docs.vapor.codes/4.0/fluent/overview/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://github.com/vapor/fluent/actions">
        <img src="https://github.com/vapor/fluent/workflows/test/badge.svg" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 5.2">
    </a>
</p>

# Fluent

Fluent is an [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping) framework for Swift.Leverage Swift's powerful type system to provide an easy-to-use interface to your database. Using Fluent focuses on creating model types that represent the data structures in your database. These models are used to perform create, read, update, and delete operations instead of writing raw queries.

## Configuration

When creating a project using `vapor new`, answer "yes" to including Fluent and choose which database driver you want to use. This will automatically add the dependencies to your new project as well as example configuration code.

```bash
vapor new app yes
```



