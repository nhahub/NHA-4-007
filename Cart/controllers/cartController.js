// const { json } = require('express');
// const CartModel = require('../models/cartModel');
// const ProductModel = require('../models/productModel');

// const getCartProducts = async (req, res) => {
//     const cartProducts = await CartModel.find({ UserId: req.user.id });
//     const cartProductIds = [];
//     let total = 0;
//     cartProducts.forEach(cartProduct => {
//         cartProductIds.push(cartProduct.ProductId);
//     });


//     // console.log(cartProductIds);
//     const Products =  await ProductModel.find({ _id: { $in: cartProductIds } });
//     Products.forEach(product => {
//         total += product.price;
//     });
//     // console.log(Products);

//     // const productDetails = productArray.push(await ProductModel.findById(cartProducts[0].ProductId));
//     // res.json(productDetails);
//     res.json({Products, total});
// }
// const addCartProduct = async (req, res) => {
//     const cartProduct = await CartModel.create(
//         {
//             UserId: req.user.id,
//             ProductId: req.params.productid
//         }
//     );
//     res.json(cartProduct);
// }

// const deleteCartProduct = async (req, res) => {
//     const cartProduct = await CartModel.findOneAndDelete(
//         {
//             UserId: req.user.id,
//             ProductId: req.params.productid
//         }
//     );
//     res.json(cartProduct);  
// }

// const checkout = async (req, res) => {
//     const cartProducts = await CartModel.deleteMany({ UserId: req.user.id });
//     // console.log(cartProducts);
//     let total = 0;
//     res.json({cartProducts});

// }

// module.exports = {
//     getCartProducts,
//     addCartProduct,
//     deleteCartProduct,
//     checkout
// }

const { json } = require('express');
const CartModel = require('../models/cartModel');
const ProductModel = require('../models/productModel');
const axios = require('axios'); //



const getCartProducts = async (req, res) => {
    console.log("--- Fetching Cart for User:", req.user.id);

    const cartItems = await CartModel.find({ UserId: req.user.id });

    if (cartItems.length === 0) {
        return res.json({ Products: [], total: 0 });
    }

    try {
        // We "ask" the Product Service for the data via HTTP
        const response = await axios.get('http://localhost:3002/products');
        const allProducts = response.data;

        // Filter the products to only include what is in the cart
        const cartProductIds = cartItems.map(item => item.ProductId);
        const filteredProducts = allProducts.filter(p => cartProductIds.includes(p._id));

        let total = 0;
        filteredProducts.forEach(p => total += p.price);

        console.log(`Matched ${filteredProducts.length} products from Product Service`);
        res.json({ Products: filteredProducts, total });

    } catch (error) {
        console.error("Failed to fetch products from Product Service:", error.message);
        res.status(500).json({ error: "Product Service Unreachable" });
    }
}

const addCartProduct = async (req, res) => {
    try {
        // DEBUGGING: Let's see exactly what the router is passing
        console.log("--- Add to Cart Triggered ---");
        console.log("User ID from Token:", req.user.id);
        console.log("Params received:", req.params);

        // POTENTIAL FIX: Check if your router uses :productId or :productid
        const pId = req.params.productid || req.params.productId;

        if (!pId) {
            console.error("ERROR: Product ID is missing from request params!");
            return res.status(400).json({ error: "Product ID missing" });
        }

        const cartProduct = await CartModel.create({
            UserId: req.user.id,
            ProductId: pId
        });

        console.log("Successfully saved to MongoDB:", cartProduct);
        res.json(cartProduct);
    } catch (error) {
        console.error("CRITICAL ERROR in addCartProduct:", error.message);
        res.status(500).json({ error: error.message });
    }
}

const deleteCartProduct = async (req, res) => {
    const pId = req.params.productid || req.params.productId;
    const cartProduct = await CartModel.findOneAndDelete({
        UserId: req.user.id,
        ProductId: pId
    });
    res.json(cartProduct);
}

const checkout = async (req, res) => {
    const result = await CartModel.deleteMany({ UserId: req.user.id });
    console.log("Checkout triggered. Items cleared:", result.deletedCount);
    res.json({ result });
}

module.exports = {
    getCartProducts,
    addCartProduct,
    deleteCartProduct,
    checkout
}