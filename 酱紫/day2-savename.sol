// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName {

    string name;
    string bio;
    uint256 age;        // 新增：年龄
    string occupation;  // 新增：职业

    // 更新添加功能，包含四个参数
    function add(string memory _name, string memory _bio, uint256 _age, string memory _occupation) public {
        name = _name;
        bio = _bio;
        age = _age;
        occupation = _occupation;
    }

    // 更新检索功能，返回四个值
    function retrieve() public view returns (string memory, string memory, uint256, string memory) {
        return (name, bio, age, occupation);
    }

    // 高效版本
    function saveAndRetrieve(string memory _name, string memory _bio, uint256 _age, string memory _occupation) public returns (string memory, string memory, uint256, string memory) {
        name = _name;
        bio = _bio;
        age = _age;
        occupation = _occupation;
        return (name, bio, age, occupation);
    }
}





// 这份学习笔记非常清晰地展示了 Solidity 中最核心的两个数据结构：**数组（Array）**和**映射（Mapping）**。通过 `PollStation`（投票站）合约的案例，我们可以将这些抽象概念转化为具体的逻辑操作。
// 以下是根据你的学习内容总结的 **Solidity 核心操作知识点**：

// ---

// ## 1. 复杂变量的声明与初始化

// 在 Solidity 中，组织数据的核心在于如何定义容器：

// * **动态数组 (Dynamic Array):** `string[] public candidateNames;`
// * 用于存储**有序**的数据列表。
// * 支持 `.push()` 操作来增加长度。


// * **映射 (Mapping):** `mapping(string => uint256) voteCount;`
// * 用于存储**键值对 (Key-Value Pairs)**。
// * 查询速度极快（$O(1)$ 时间复杂度），适合做“账本”或“计数器”。



// ---

// ## 2. 数据的写入操作 (State-Changing)

// 当函数需要修改区块链上的状态（State Variables）时，需要消耗 Gas。

// * **向数组添加元素:** 使用 `.push(_value)`。这会在数组末尾分配新空间并存入数据。
// * **更新映射数值:** 使用 `map[key] = value` 或 `map[key] += 1`。
// * *注意：* 在 Solidity 中，如果访问一个不存在的键，映射会返回该类型的**默认值**（如 `uint256` 返回 `0`）。


// * **内存关键字 (`memory`):** 对于 `string` 或 `array` 类型的输入参数，必须指定存储位置。`memory` 表示该数据仅在函数执行期间存在，不会永久存储，从而节省 Gas。

// ---

// ## 3. 数据的读取操作 (Read-Only)

// 如果函数不修改任何数据，只需读取，应使用修饰符以优化性能。

// * **`view` 修饰符:** 告诉编译器该函数**只读**。在外部调用（如通过钱包或前端）时，`view` 函数是不消耗 Gas 的。
// * **返回复杂类型:** 如果返回数组或字符串，返回类型定义需写成 `returns (string[] memory)`。
// * **自动 Getter 函数:** 当变量声明为 `public` 时（如 `candidateNames`），Solidity 会自动生成一个同名的只读函数，但数组的自动 Getter 通常需要传入索引（Index）来获取单个元素。

// ---

// ## 4. 函数逻辑构造

// 一个标准的 Solidity 功能函数通常遵循以下模式：

// | 步骤 | 知识点 | 示例 (PollStation) |
// | --- | --- | --- |
// | **输入** | 参数定义与位置 | `(string memory _candidateNames)` |
// | **可见性** | 权限控制 | `public` (任何人可调) |
// | **逻辑处理** | 状态更新 | `voteCount[_name] += 1` |
// | **输出** | 返回声明 | `returns (uint256)` |

// ---

// ## 5. 进阶逻辑预告：Require 与 Address

// 在你的“可能改进”中提到了防止重复投票，这涉及到了接下来的核心知识点：

// * **`msg.sender`:** 全局变量，代表当前调用合约的人的地址（`address`）。
// * **`require()`:** 逻辑检查语句。例如 `require(!hasVoted[msg.sender], "Already voted");`，如果条件不成立，交易会回滚并报错。
