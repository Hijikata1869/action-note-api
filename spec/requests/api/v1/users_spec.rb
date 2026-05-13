require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    context "正常系" do
      it "正しいパラメーターでPOSTすると201が返ること" do
      end

      it "正しいパラメーターでPOSTするとUser.countが1増えること" do
      end
    end

    context "異常系" do
    end

    context "境界値" do
    end
  end
end
