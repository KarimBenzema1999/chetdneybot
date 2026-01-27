import asyncio
import re
from aiogram import Bot, Dispatcher, types
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from aiogram.filters import Command
from apscheduler.schedulers.asyncio import AsyncIOScheduler

TOKEN = "8176725927:AAF6aRCYy7tza93yyRalAQjY4RC1wNH9v7I"
ADMIN_ID = 406997926          # твой Telegram ID
CHANNEL_ID =  -1001936696365   # chat_id канала
MESSAGE_ID = 368               # message_id сообщения

bot = Bot(TOKEN)
dp = Dispatcher()

keyboard = InlineKeyboardMarkup(inline_keyboard=[
    [InlineKeyboardButton(text="🔁 Сброс", callback_data="reset")],
    [InlineKeyboardButton(text="➕ Один день спокойствия", callback_data="plus")]
])

@dp.message(Command("start"))
async def start(msg: types.Message):
    if msg.from_user.id == ADMIN_ID:
        await msg.answer("Выбери действие:", reply_markup=keyboard)

@dp.callback_query()
async def handle_buttons(call: types.CallbackQuery):
    if call.from_user.id != ADMIN_ID:
        await call.answer("Нет доступа ❌", show_alert=True)
        return

    # Получаем текущее сообщение из канала
    msg = await bot.get_message(CHANNEL_ID, MESSAGE_ID)
    text = msg.text

    # Ищем число в тексте
    number = int(re.search(r"\d+", text).group())

    if call.data == "reset":
        new_number = 0
    elif call.data == "plus":
        new_number = number + 1
    else:
        return

    # Меняем только число
    new_text = re.sub(r"\d+", str(new_number), text)

    await bot.edit_message_text(
        chat_id=CHANNEL_ID,
        message_id=MESSAGE_ID,
        text=new_text
    )

    await call.answer("Готово ✅")

async def ask_daily():
    await bot.send_message(
        ADMIN_ID,
        "Обновим счётчик?",
        reply_markup=keyboard
    )

async def main():
    scheduler = AsyncIOScheduler()
    scheduler.add_job(ask_daily, "cron", hour=10, minute=0)
    scheduler.start()
    await dp.start_polling(bot)

asyncio.run(main())
