var express = require("express");
var router = express.Router();

/* GET home page. */
router.get("/", async (req, res, next) => {
    res.json({ foo: "bar" });
});

/* GET home page. */
router.get("/test", async (req, res, next) => {
    res.json({ foo: "BOOM!!", now: new Date() });
});

router.get("/random", function (req, res, next) {
    res.json({ value: Math.random() * 100 });
});

const items = {
    1: { name: "불닭볶음면", price: 1000 },
    2: { name: "스팸", price: 2000 },
    3: { name: "펜폴즈 쿠능가힐 쉬라즈", price: 22000 },
    4: { name: "어죽", price: 6000 },
    5: { name: "그라함 식스 그레이프", price: 39000 },
    6: { name: "샤또 데레즐라 토카이 아쑤 6 푸토뇨스", price: 110000 },
    7: { name: "샥쇼카", price: 10000 },
    8: { name: "안띠쿠초라", price: 10000 },
    9: { name: "보르쉬", price: 13000 },
    10: { name: "메도빅", price: 8000 },
    11: { name: "루스토 산 에밀리오 페드로 히메네즈", price: 38000 },
};

router.get("/item/:itemId", function (req, res, next) {
    const itemId = req?.params?.["itemId"];
    res.json({ item: { ...items[itemId], itemId } });
});

router.get("/items", function (req, res, next) {
    res.json({
        items: Object.entries(items).map(([key, value]) => ({
            itemId: key,
            ...value,
        })),
    });
});

module.exports = router;
