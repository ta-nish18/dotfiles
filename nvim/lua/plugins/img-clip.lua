return {
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        copy_images = true,
        embed_images_as_base64 = false,
        dir_path = "assets",
        file_name = "%Y-%m-%d-%H-%M-%S",
        prompt_for_file_name = false,
        use_absolute_path = false,
        relative_to_current_file = true,
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
  }
}
